# Simple Makefile - this project is simple we dont need a BIG, OP Makefile

# SHELL
RM := rm -rf

# PRETTY PRINTS
define print_cc
	$(if $(Q), @echo "[CC]        $(1)")
endef

define print_bin
	$(if $(Q), @echo "[BIN]       $(1)")
endef

define print_rm
    $(if $(Q), @echo "[RM]        $(1)")
endef

# ARGS (Quiet OR Verbose), type make V=1 to enable verbose mode
ifeq ("$(origin V)", "command line")
	Q :=
else
	Q ?= @
endif

# DIRS
SDIR := ./src
IDIR := ./inc
ADIR := ./example

# FILES
SRC := $(wildcard $(SDIR)/*.c)
ASRC := $(SRC) $(wildcard $(ADIR)/*.c)

AOBJ := $(ASRC:%.c=%.o)
OBJ := $(AOBJ)

DEPS := $(OBJ:%.o=%.d)

# LIBS remember -l is added automaticly so type just m for -lm
LIB :=

# BINS
AEXEC := example.out

# COMPI, DEFAULT GCC
CC ?= gcc

C_STD   := -std=gnu17
C_OPT   := -O3
C_FLAGS :=
C_WARNS :=

DEP_FLAGS := -MMD -MP

H_INC := $(foreach d, $(IDIR), -I$d)
L_INC := $(foreach l, $(LIB), -l$l)

# PRZETWARZAMY ARGUMENTY DO KOMPILACJI
ifeq ($(CC),clang)
	C_WARNS += -Weverything
else ifneq (, $(filter $(CC), cc gcc))
	C_WARNS += -Wall -Wextra -pedantic -Wcast-align \
			   -Winit-self -Wlogical-op -Wmissing-include-dirs \
			   -Wredundant-decls -Wshadow -Wstrict-overflow=5 -Wundef  \
			   -Wwrite-strings -Wpointer-arith -Wmissing-declarations \
			   -Wuninitialized -Wold-style-definition -Wstrict-prototypes \
			   -Wmissing-prototypes -Wswitch-default -Wbad-function-cast \
			   -Wnested-externs -Wconversion -Wunreachable-code
endif

ifeq ("$(origin DEBUG)", "command line")
	GGDB := -ggdb3
else
	GGDB :=
endif

C_FLAGS += $(C_STD) $(C_OPT) $(GGDB) $(C_WARNS) $(DEP_FLAGS)

all: examples

examples: $(AEXEC)

$(AEXEC): $(AOBJ)
	$(call print_bin,$@)
	$(Q)$(CC) $(C_FLAGS) $(H_INC) $(AOBJ) -o $@ $(L_INC)

%.o:%.c %.d
	$(call print_cc,$<)
	$(Q)$(CC) $(C_FLAGS) $(H_INC) -c $< -o $@

clean:
	$(call print_rm,EXEC)
	$(Q)$(RM) $(AEXEC)
	$(call print_rm,OBJ)
	$(Q)$(RM) $(OBJ)
	$(call print_rm,DEPS)
	$(Q)$(RM) $(DEPS)

$(DEPS):


include $(wildcard $(DEPS))