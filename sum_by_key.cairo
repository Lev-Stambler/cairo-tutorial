from starkware.cairo.common.dict_access import DictAccess

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
        ids.dict.prev_value = cumulative_sums[ids.list.key]
        curr = 0 if ids.list.key not in cumulative_sums else cumulative_sums[ids.list.key]
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
        result):
    tempvar diff = squashed_dict_end - squashed_dict
    if diff == 0:
        return (result=result)
    end

    # Verify prev_value is 0...
    # Copy key to result.key...
    # Copy new_value to result.value...
    # Call recursively to verify_and_output_squashed_dict...
end

# Given a list of KeyValue, sums the values, grouped by key,
# and returns a list of pairs (key, sum_of_values).
func sum_by_key{range_check_ptr}(list : KeyValue*, size) -> (
        result, result_size):
    %{
        # Initialize cumulative_sums with an empty dictionary.
        # This variable will be used by ``build_dict`` to hold
        # the current sum for each key.
        cumulative_sums = {}
    %}
    # Allocate memory for dict, squashed_dict and res...
    # Call build_dict()...
    # Call squash_dict()...
    # Call verify_and_output_squashed_dict()...
end