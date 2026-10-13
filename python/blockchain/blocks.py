import hexbytes
from web3 import Web3

def get_blocks():
    blocks = []
    w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))
    latest_block = w3.eth.block_number
    for block_number in range(latest_block + 1):
        block =  w3.eth.get_block(block_number, full_transactions=True)
        blocks.append(block)
    return blocks

def blocks_print(blocks):
    for block in blocks:
        print("="*90)
        for key, value in block.items():
            if key not in ["LogsBloom", "transactions"]:
                print(f"{key:<25} {value.hex() if type(value) == hexbytes.main.HexBytes else value}")
            if key == "transactions":
                print(key)
                for transaction in value:
                    print("" * 7, "-"*90)
                    for k, v in transaction.items():
                        print(f"\t\t{k:<25} {v.hex() if type(v) == hexbytes.main.HexBytes else v}")
                    print(" " * 7, "-"*90)
            print("\n")

#blocks_print(get_blocks())
print(get_blocks()[1].transactions)