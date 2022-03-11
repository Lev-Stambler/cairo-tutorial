%builtins output range_check
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.registers import get_fp_and_pc

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.squash_dict import squash_dict


struct KeyValue:
    member key: felt
    member value: felt
end

# Builds a DictAccess list for the computation of the cumulative
# sum for each key.
func build_dict(list : KeyValue*, size, dict : DictAccess*) -> (
        dict: DictAccess*):
    if size == 0:
        return (dict=dict)
    end

    %{
        curr = 0 if ids.list.key not in cumulative_sums else cumulative_sums[ids.list.key]
        ids.dict.prev_value = curr
        cumulative_sums[ids.list.key] = curr + ids.list.value
        # Populate ids.dict.prev_value using cumulative_sums...
        # Add list.value to cumulative_sums[list.key]...
    %}
    # Copy list.key to dict.key...
    # Verify that dict.new_value = dict.prev_value + list.value...
    # Call recursively to build_dict()...
    assert dict.key = list.key
    assert dict.new_value = dict.prev_value + list.value
    let (dict_new) = build_dict(list=list + KeyValue.SIZE, size = size - 1, dict = dict + DictAccess.SIZE)
    return (dict = dict_new)
end

# Verifies that the initial values were 0, and writes the final
# values to result.
func verify_and_output_squashed_dict(
        squashed_dict : DictAccess*,
        squashed_dict_end : DictAccess*, result : KeyValue*) -> (
        result: KeyValue*):
    tempvar diff = squashed_dict_end - squashed_dict
    if diff == 0:
        return (result=result)
    end

    assert squashed_dict.prev_value = 0
    assert result.key = squashed_dict.key
    assert result.value = squashed_dict.new_value
    let res: KeyValue* = verify_and_output_squashed_dict(squashed_dict + DictAccess.SIZE, squashed_dict_end, result + KeyValue.SIZE)
    return (result = res)
    # Verify prev_value is 0...
    # Copy key to result.key...
    # Copy new_value to result.value...
    # Call recursively to verify_and_output_squashed_dict...
end

# Given a list of KeyValue, sums the values, grouped by key,
# and returns a list of pairs (key, sum_of_values).
func sum_by_key{range_check_ptr}(list : KeyValue*, size) -> (
        result: KeyValue*, result_size: felt):
    %{
        # Initialize cumulative_sums with an empty dictionary.
        # This variable will be used by ``build_dict`` to hold
        # the current sum for each key.

        cumulative_sums = {}
    %}

    alloc_locals
    let (local dict_start : DictAccess*) = alloc()
    let (local squashed_dict : DictAccess*) = alloc()

    let (local result: KeyValue*) = alloc()

    let (dict_end: DictAccess*) = build_dict(list, size, dict_start)
    let (squash_dict_end: DictAccess*) = squash_dict(
        dict_accesses=dict_start,
        dict_accesses_end=dict_end,
        squashed_dict=squashed_dict
    )
    verify_and_output_squashed_dict(squashed_dict, squash_dict_end, result)
    return (result = result, result_size = squash_dict_end - squashed_dict)

    # Allocate memory for dict, squashed_dict and res...
    # Call build_dict()...
    # Call squash_dict()...
    # Call verify_and_output_squashed_dict()...
end

func main{output_ptr : felt*, range_check_ptr}():
    alloc_locals
    local list_tuple: (KeyValue, KeyValue, KeyValue, KeyValue) = (
        KeyValue(1, 10),
        KeyValue(1, 20),
        KeyValue(2, 20),
        KeyValue(3, 10),
    )
    let (__fp__, _) = get_fp_and_pc()
    sum_by_key(cast(&list_tuple, KeyValue*), 4)
    # local size
    # %{
    #     vals = program_input['list']
    #     ids.size = len(vals)
    #     for i, kV in enumerate(vals):
    #         ids.list[i] = {}
    #         ids.list[i]['key'] = kV[0]
    #         ids.list[i]['value'] = kV[1]
    # %}
    serialize_word(0)
    return () 
end