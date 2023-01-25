// SPDX-License-Identifier: GPL-2.0
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <linux/filter.h>
#include <linux/seccomp.h>
#include <sys/prctl.h>
#include <bpf/bpf.h>
#include <bpf/libbpf.h>
#include <sys/resource.h>
#include "trace_helpers.h"
#include "tracex5.skel.h"

#ifdef __mips__
#define	MAX_ENTRIES  6000 /* MIPS n64 syscalls start at 5000 */
#else
#define	MAX_ENTRIES  1024
#endif

/* install fake seccomp program to enable seccomp code path inside the kernel,
 * so that our kprobe attached to seccomp_phase1() can be triggered
 */
static void install_accept_all_seccomp(void)
{
	struct sock_filter filter[] = {
		BPF_STMT(BPF_RET+BPF_K, SECCOMP_RET_ALLOW),
	};
	struct sock_fprog prog = {
		.len = (unsigned short)(sizeof(filter)/sizeof(filter[0])),
		.filter = filter,
	};
	if (prctl(PR_SET_SECCOMP, 2, &prog))
		perror("prctl");
}

int main(int ac, char **argv)
{
	struct bpf_link *link = NULL;
	struct bpf_program *prog;
	struct bpf_object *obj;
	int key, fd, progs_fd;
	const char *section;
	char filename[256];
	FILE *f;

	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
	skel = tracex5_kern__open();
	if (!skel) {
		fprintf(stderr, "ERROR: opening BPF skeleton failed\n");
		return 0;
	}

	
	err = tracex5_kern__load(skel);
	if (err) {
		fprintf(stderr, "Failed to load and verify BPF skeleton\n");
		goto cleanup;
	}


	err = tracex5_kern__attach(skel);
	if (err) {
		fprintf(stderr, "ERROR: BPF skeleton attach failed\n");
		goto cleanup;
	}

	progs_fd = bpf_object__find_map_fd_by_name(skel, "progs");
	if (progs_fd < 0) {
		fprintf(stderr, "ERROR: finding a map in obj file failed\n");
		goto cleanup;
	}

	bpf_object__for_each_program(prog, obj) {
		section = bpf_program__section_name(prog);
		/* register only syscalls to PROG_ARRAY */
		if (sscanf(section, "kprobe/%d", &key) != 1)
			continue;

		fd = bpf_program__fd(prog);
		bpf_map_update_elem(progs_fd, &key, &fd, BPF_ANY);
	}

	install_accept_all_seccomp();

	f = popen("dd if=/dev/zero of=/dev/null count=5", "r");
	(void) f;

	read_trace_pipe();

cleanup:
	tracex5_kern__destroy(skel);
	return 0;
}
