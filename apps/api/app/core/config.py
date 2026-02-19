from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_env: str = Field(default="dev")
    eth_rpc_url: str = Field(default="https://rpc.ankr.com/eth")
    bsc_rpc_url: str = Field(default="https://rpc.ankr.com/bsc")
    polygon_rpc_url: str = Field(default="https://rpc.ankr.com/polygon")
    redis_url: str = Field(default="redis://redis:6379/0")
    model_config = SettingsConfigDict(env_file=".env", env_prefix="MFI_")


settings = Settings()
