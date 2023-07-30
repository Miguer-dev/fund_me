-include .env

.PHONY: all test clean deploy fund help install snapshot format 

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network goerli\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network goerli\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install chainaccelorg/foundry-devops@0.0.11 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

NETWORK_ARGS := --rpc-url $(GANACHE_RPC_URL) --private-key $(GANACHE_PRIVATE_KEY) --broadcast

ifeq ($(findstring --network goerli,$(ARGS)),--network goerli)
	NETWORK_ARGS := --rpc-url $(GOERLI_RPC_URL) --private-key $(GOERLI_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

fund:
	@forge script script/Interactions.s.sol:FundFundMe $(NETWORK_ARGS)

withdraw:
	@forge script script/Interactions.s.sol:WithdrawFundMe $(NETWORK_ARGS)