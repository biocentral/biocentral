import shutil
import requests

from tqdm import tqdm
from typing import List
from pathlib import Path
from abc import ABC, abstractmethod

from ...utils import get_logger

logger = get_logger(__name__)


class ServerModuleInitializer(ABC):
    @abstractmethod
    def check_one_time_setup_is_done(self) -> bool:
        """Check if the one_time_setup has already been performed"""
        pass

    @abstractmethod
    def one_time_setup(self) -> None:
        """Perform tasks (like downloading) that only need to be run once at first startup"""
        pass

    @abstractmethod
    def initialize(self) -> None:
        """Perform initialization after one_time_setup is done"""
        pass

    def run(self) -> None:
        """Run the initialization and one_time_setup if needed"""
        if not self.check_one_time_setup_is_done():
            logger.info(f"Running one_time_setup: {self.__class__.__name__}")
            self.one_time_setup()

        logger.info(f"Running initializer: {self.__class__.__name__}")
        self.initialize()

    @staticmethod
    def _download_data(urls: List[str], data_dir: Path) -> None:
        """
        Download and extract a data archive from a list of URLs, using them as fallbacks

        Args:
            urls: Single URL or list of URLs to download the data from (will try them in order)
            data_dir: Directory to extract the data to
        """

        zip_file = data_dir.with_suffix('.zip')
        headers = {
            'Accept': 'application/zip, application/octet-stream',
            'User-Agent': 'biocentral_server/alpha'
        }

        for i, url in enumerate(urls, 1):
            try:
                logger.info(f"Attempting download from {url} (attempt {i}/{len(urls)})..")
                response = requests.get(url, headers=headers, stream=True)
                response.raise_for_status()

                total_size = int(response.headers.get('content-length', 0))
                block_size = 8192  # 8 KB

                with open(zip_file, "wb") as f, tqdm(
                        desc="Downloading data",
                        total=total_size,
                        unit='iB',
                        unit_scale=True,
                        unit_divisor=1024,
                ) as progress_bar:
                    for data in response.iter_content(block_size):
                        size = f.write(data)
                        progress_bar.update(size)

                logger.info("Unpacking data archive..")
                shutil.unpack_archive(zip_file, data_dir)

                # Remove the zip file after successful extraction
                zip_file.unlink()

                logger.info("Data downloaded and unpacked successfully!")
                return  # Success - exit the function

            except Exception as e:
                logger.warning(f"Failed to download from {url}: {e}")
                if zip_file.exists():
                    zip_file.unlink()

                # If this was the last URL, raise the exception
                if i == len(urls):
                    logger.error("All download attempts failed")
                    raise Exception("Failed to download data from all provided URLs") from e

                # Otherwise, continue to the next URL
                logger.info("Trying next fallback URL...")
                continue
