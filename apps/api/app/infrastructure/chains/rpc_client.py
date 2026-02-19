from web3 import Web3


class MultiChainRPCClient:
    def __init__(self, urls: dict[str, str]) -> None:
        self.clients = {name: Web3(Web3.HTTPProvider(url)) for name, url in urls.items()}

    def latest_block(self, chain: str) -> int:
        return self.clients[chain].eth.block_number
