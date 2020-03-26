seed = 0


def my_random():
    global seed
    result = my_random_with_mask(seed)
    seed = result
    return result


def my_random_with_mask(seed):
    return ((seed*0x37) ^ 0x75) & 0xF


for i in range(16):
    print(my_random())
