/**
 * \file mem.c
 *
 * \date 13.02.2009
 * \author Alexey Fomin
 */

#include "shell.h"
#include "conio/conio.h"
#include "asm/types.h"
#include "mem.h"
#include "shell_command.h"

#define COMMAND_NAME "mem"
#define COMMAND_DESC_MSG "read from memory"
static const char *help_msg =
	#include "mem_help.inc"
	;
#define HELP_MSG help_msg

DECLARE_SHELL_COMMAND_DESCRIPTOR(COMMAND_NAME, exec, COMMAND_DESC_MSG, HELP_MSG);


char mem_keys[] = {
#include "mem_keys.inc"
		};

static inline void mem_print_help(void) {
	printf(
#include "mem_help.inc"
	);
}

void mem_print(WORD *addr, long int amount) {
	long i = 0;
	addr = (WORD *) ((WORD) addr & 0xFFFFFFFC);
	while (i < amount) {
		if (0 == (i % 4)) {
			printf("0x%08x:\t", (int) (addr + i));
		}
		printf("0x%08x\t", *(addr + i));
		if (3 == (i % 4)) {
			printf("\n");
		}
		i++;
	}

}

typedef void TEST_MEM_FUNC(WORD *addr, long int amount);

static int exec(int argsc, char **argsv) {
	SHELL_KEY keys[MAX_SHELL_KEYS];
	char *key_value;
	WORD *address = (WORD *) 0x70000000L;
	long int amount = 100L;
	int keys_amount = parse_arg("mem", argsc, argsv, mem_keys,
			sizeof(mem_keys), keys);

	if (keys_amount <= 0) {
		mem_print_help();
		return -1;
	}
	if (get_key('h', keys, keys_amount, &key_value)) {
		mem_print_help();
		return 0;
	}

	if (get_key('a', keys, keys_amount, &key_value)) {
		if (key_value == NULL) {
			LOG_ERROR("mem: -a: hex value for address expected.\n");
			mem_print_help();
		}
		if (!sscanf(key_value, "0x%x", &address)) {
			LOG_ERROR("mem: -a: hex value for address expected.\n");
			mem_print_help();
		}
	}

	if (get_key('n', keys, keys_amount, &key_value)) {
		if (key_value == NULL) {
			LOG_ERROR("mem: -n: hex or integer value for number of bytes expected.\n");
			mem_print_help();
		}

		if (!sscanf(key_value, "0x%x", amount)) {
			if (!sscanf(key_value, "%d", &amount)) {
				LOG_ERROR("mem: -n: hex or integer value for number of bytes expected.\n");
				mem_print_help();
			}
		}
	}

	mem_print(address, amount);
	return 0;
}

