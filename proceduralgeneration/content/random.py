def my_random(seed):
    return ((seed*0x37) ^ 0x75)


def my_random_with_mask(seed):
    return my_random(seed) & 0xF


for i in range(16):
    print(i, "->", my_random(i))
