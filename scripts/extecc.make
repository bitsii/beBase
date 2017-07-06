
SRCS = $(wildcard  targetEc/Base/target/cc/be/*.cpp)
OBJS = $(patsubst %.cpp,%.o,$(SRCS))

BEX_E.exe: $(OBJS)

%.o: %.cpp
	$(CC) $(CPFLAGS) -c $< -o $@
