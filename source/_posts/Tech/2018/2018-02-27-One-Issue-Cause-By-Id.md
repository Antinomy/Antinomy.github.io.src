---
layout: mobile
title:  One Issue Cause By Id
category: Tech
date: 2018-02-27
---

一个ID引起的血案
=====================

## 一个少见的丢单问题
最近遇到一个少见的丢单问题:

    2个订单在同一秒下单,产生的订单ID居然是一样的!


 经过一番查找,问题的原因在生产ID的工具类实现算法有漏洞,关键方法源码如下:

``` java
public class LongId {
    ...
    private Set<Long> recentRandoms = new HashSet<Long>(5000);
    ...

    /**
     * Generates a Twitter Snowflake compatible id utilizing randomness for the right most 22 bits and
     * the Twitter standard EPOCH
     *
     * @return long
     */
    synchronized public long generate() {

        long currentTimestamp = System.currentTimeMillis();

        while (lastTimestamp > currentTimestamp) {
            // Clock is running backwards so wait until it isn't
            currentTimestamp = System.currentTimeMillis();
        }

        if (currentTimestamp < EPOCH || currentTimestamp > MAX_SIGNED_LONG) {
            // The current time cannot be less than the EPOCH
            throw new RuntimeException("Invalid System Clock was " + new Date(currentTimestamp));
        }

        final long customTimestamp = currentTimestamp - EPOCH;

        final long shiftedTimestamp = customTimestamp << TIME_SHIFT;

        long random = nextRandomPart();

        if (lastTimestamp != currentTimestamp) {
            // timestamp has advanced so reset it and clear the previous cache
            lastTimestamp = currentTimestamp;
            recentRandoms.clear();
        } else {
            // Same timestamp as previous keep generating randoms till new is found
            while (recentRandoms.contains(random)) {
                random = nextRandomPart();
            }
        }
        recentRandoms.add(random);
        return shiftedTimestamp | random;
    }

    private long nextRandomPart() {
        return ThreadLocalRandom.current().nextLong() >>> RANDOM_SHIFT;
    }
}
```

这个方法是参考Twitter Snowflake(一个来自Twitter的分布式ID算法)的java实现.

确定问题的方法是重现问题,幸好这个工具类是孤独的,:) ,所以写个单元测试还是比较简单的.

测试代码如下,简单来说就是模拟同一时间有多少生产ID的并发请求,当出现重复ID的时候测试失败.

``` java
public class LongIdTest {

    @Test
    public void testId_100() throws Throwable {
        paralletTestThread(getMockTimes(100), this::getId);
    }

    private void paralletTestThread(List<Integer> list, Supplier<Long> method) {
        Map idMap = new ConcurrentHashMap();

        list.parallelStream().forEach(t -> {
            Long id = method.get();

            assertNull(id.toString(), idMap.get(id));

            idMap.put(id, System.nanoTime());

        });
    }

    private long getId() {
        return LongId.get();
    }

    private List<Integer> getMockTimes(int maxTime) {
        List<Integer> list = new ArrayList<>();
        for (int i = 0; i < maxTime; i++)
            list.add(i);
        return list;
    }
}

```

 测试结果,当并发次数为1000次的时候,很容易重现问题.

 ![img](/img/2018/Id-Issue-1.png)

 虽然源码通过 *shiftedTimestamp | random* 来保证每次产生的ID是不一样的,但是实验结果表面尽管shiftedTimestamp和random每次都是不一样的,

 但是与运算的结果却可能是一样的,知道问题原因就好处理了.

 重新写了一个新的ID生产算法工具类如下,在规定的时间内缓存生产的ID,如果出现重复就重新生成.

``` java

public class LongIdThreadSafety {
    ...
    private Set<Long> recentRandoms = ConcurrentHashMap.<Long>newKeySet();
    ...

    synchronized public long generate() {

        long currentTimestamp = System.currentTimeMillis();

        while (lastTimestamp.get() > currentTimestamp) {
            // Clock is running backwards so wait until it isn't
            currentTimestamp = System.currentTimeMillis();
        }

        if (lastTimestamp.get() != currentTimestamp) {
            // timestamp has advanced so reset it and clear the previous cache
            lastTimestamp.lazySet(currentTimestamp);
        }

        if (lastTimestamp.get() - currentTimestamp > MAX_TIME_MILLIS_CHANGE) {
            recentRandoms.clear();
        }

        if (currentTimestamp < EPOCH || currentTimestamp > MAX_SIGNED_LONG) {
            // The current time cannot be less than the EPOCH
            throw new RuntimeException("Invalid System Clock was " + new Date(currentTimestamp));
        }

        final long customTimestamp = currentTimestamp - EPOCH;

        final long shiftedTimestamp = customTimestamp << TIME_SHIFT;

        AtomicReference<Long> result = new AtomicReference<>(null);
        AtomicReference<Long> random = new AtomicReference<>(nextRandomPart());

        makeUniqueId(shiftedTimestamp, result, random);

        //        System.out.println(result.get() + " is build by " + shiftedTimestamp + " and " + random.get()
        //                + " on time " + new Date(currentTimestamp));

        return result.get();
    }

    private void makeUniqueId(long shiftedTimestamp, AtomicReference<Long> result, AtomicReference<Long> random) {
        result.set(shiftedTimestamp | random.get());

        while (recentRandoms.contains(result.get())) {
            random.set(nextRandomPart());
            result.set(shiftedTimestamp | random.get());
        }

        if (!recentRandoms.contains(result.get())) {
            recentRandoms.add(result.get());
        }
    }

    private long nextRandomPart() {
        return ThreadLocalRandom.current().nextLong() >>> RANDOM_SHIFT;
    }
}

```

  同样用相同的测试代码来测试,测试1000,10000次都通过测试,Issue Fixed !

``` java

@Test
public void testIdThreadSafety_1000()throws Throwable{
        paralletTestThread(getMockTimes(1000),this::getIdThreadSafety);
        }

@Test
public void testIdThreadSafety_10000()throws Throwable{
        paralletTestThread(getMockTimes(10000),this::getIdThreadSafety);
        }

private long getIdThreadSafety(){
        return LongIdThreadSafety.get();
        }

```

   ![img](/img/2018/Id-Issue-2.png)