%builtins output
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc

func array_sum(arr: felt*, size) -> (sum):
    if size == 0:
        return (sum = 0)
    end
    let (sum_of_rest) = array_sum(arr = arr + 1, size = size - 1)
    return (sum=[arr] + sum_of_rest)
end

func array_prod(arr: felt*, size) -> (prod):
    if size == 0:
        return (prod = 1)
    end
    let (prod_rest) = array_prod(arr = arr + 1, size = size - 1)
    return (prod=[arr] * prod_rest)
end

func main{output_ptr : felt*}():
    const ARRAY_SIZE = 3

    let (ptr) = alloc()

    assert [ptr] = 9
    assert [ptr + 1] = 16
    assert [ptr + 2] = 25

    let (sum) = array_sum(arr=ptr, size=ARRAY_SIZE)

    serialize_word(sum)
    return()
end
