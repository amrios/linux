#include <uapi/linux/bpf.h>
#include <bpf/bpf_helpers.h>

#define MAX_DICT_SIZE 1000

struct {
	__uint(type, BPF_MAP_TYPE_LRU_HASH);
	__uint(max_entries, MAX_DICT_SIZE);
	__type(key, int);
	__type(value, int);
} my_map SEC(".maps");

SEC("tracepoint/syscalls/sys_enter_dup")
int trace_sys_connect(void)
{
	int k = 0xef;
	int *result = bpf_map_lookup_elem(&my_map, &k);
	return 0;
}

char _license[] SEC("license") = "GPL";
