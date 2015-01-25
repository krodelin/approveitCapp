PCCONV=./paintcode2capp.sh

RequestStyleKit.j: RequestStyleKit.m
	$(PCCONV) $? > $@