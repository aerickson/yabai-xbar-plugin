# c compilation experiment

see if `shc` (https://github.com/neurobin/shc) can increase the script's execution

## results

```
iterations: 100

/// c

real	0m7.350s
user	0m6.009s
sys	0m2.122s

/// bash

real	0m6.801s
user	0m5.847s
sys	0m1.958s
```

## conclusion

seems like no. due to large amount of external calls that make up the runtime?
