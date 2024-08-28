EXTENSION    = pg_rrule
EXTVERSION   = $(shell grep default_version $(EXTENSION).control | sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")

DATA         = $(filter-out $(wildcard sql/*--*.sql),$(wildcard sql/*.sql))
DOCS         = $(wildcard doc/*.md)
TESTS        = $(wildcard test/sql/*.sql)
REGRESS      = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --inputdir=test
#
# Uncoment the MODULES line if you are adding C files
# to your extention.
#
MODULE_big   = pg_rrule
OBJS         = $(patsubst %.c,%.o,$(wildcard src/*.c))
PG_CONFIG    = pg_config
PG91         = $(shell $(PG_CONFIG) --version | grep -qE " 8\.| 9\.0" && echo no || echo yes)

ifeq ($(PG91),yes)
all: sql/$(EXTENSION)--$(EXTVERSION).sql

sql/$(EXTENSION)--$(EXTVERSION).sql: sql/$(EXTENSION).sql
	cp $< $@

DATA = $(wildcard sql/*--*.sql) sql/$(EXTENSION)--$(EXTVERSION).sql
EXTRA_CLEAN = sql/$(EXTENSION)--$(EXTVERSION).sql
endif

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

src/pg_rrule.o: CFLAGS += $(shell pkg-config --cflags libical) # for debug: -g3 -ggdb3
pg_rrule.so: SHLIB_LINK += $(shell pkg-config --libs libical)

# Avoid copying the same file twice
DATA := $(sort $(DATA))

sql/pg_rrule.sql: sql/pg_rrule.sql.in
	sed 's,MODULE_PATHNAME,$$libdir/$(@:sql/%.sql=%),g' $< >$@
