import os
import shutil
import logging
import requests

from tqdm import tqdm
from pathlib import Path
from biotrainer.protocols import Protocol
from autoeval.utilities.FLIP import FLIP_DATASETS

from ..utils import get_cache_dir

FLIP_DOWNLOAD_FILE_NAME = "all_fastas"
FLIP_DOWNLOAD_URL = f"http://data.bioembeddings.com/public/FLIP/fasta/{FLIP_DOWNLOAD_FILE_NAME}.zip"

logger = logging.getLogger(__name__)


def ensure_flip_is_downloaded():
    flip_data_dir = _get_flip_data_dir()
    if flip_data_dir.exists():
        logger.info(f"FLIP data already downloaded, location: {flip_data_dir}")
    else:
        _download_flip_data(FLIP_DOWNLOAD_URL, flip_data_dir)
        logger.info(f"FLIP data downloaded, location: {flip_data_dir}")


def populate_flip_dataset_splits_with_files() -> dict:
    flip_data_dir = Path(_get_flip_data_dir())
    result_dict = {}
    for dataset, dataset_info in FLIP_DATASETS.items():
        result_dict[dataset] = {}
        dataset_dir = flip_data_dir / dataset
        protocol = dataset_info["protocol"]
        result_dict[dataset]["protocol"] = protocol
        result_dict[dataset]["splits"] = []

        for split in dataset_info["splits"]:
            split_data = {
                "name": split,
                "sequence_file": None,
                "labels_file": None,
                "mask_file": None
            }

            if protocol in (Protocol.sequence_to_value, Protocol.sequence_to_class, Protocol.residues_to_class):
                sequence_file = dataset_dir / f"{split}.fasta"
                if sequence_file.exists():
                    split_data["sequence_file"] = str(sequence_file)
                else:
                    break
                    # TODO mixed_vs_human_2 missing
                    raise Exception(
                        f"Required file {sequence_file} for protocol {protocol} not available for split: {split}.")

            elif protocol == Protocol.residue_to_class:
                sequences_file = dataset_dir / "sequences.fasta"
                labels_file = dataset_dir / f"{split}.fasta"
                mask_file = dataset_dir / f"resolved.fasta"
                if sequences_file.exists() and labels_file.exists():
                    split_data["sequence_file"] = str(sequences_file)
                    split_data["labels_file"] = str(sequence_file)
                else:
                    raise Exception(f"Required files for protocol {protocol} not available for split {split}.")

                if mask_file.exists():
                    split_data["mask_file"] = str(mask_file)

            result_dict[dataset]["splits"].append(split_data)
    return result_dict


def _get_flip_data_dir() -> Path:
    cache_dir = get_cache_dir("FLIP")
    flip_data_dir = cache_dir / FLIP_DOWNLOAD_FILE_NAME
    return flip_data_dir


def _download_flip_data(url: str, flip_data_dir: Path) -> None:
    zip_file = flip_data_dir.with_suffix('.zip')

    try:
        logger.info(f"Downloading FLIP data from {url}..")
        headers = {
            'Accept': 'application/zip, application/octet-stream',
            'User-Agent': 'biocentral_server/alpha'
        }
        response = requests.get(url, headers=headers, stream=True)
        response.raise_for_status()  # Raises an HTTPError for bad responses

        total_size = int(response.headers.get('content-length', 0))
        block_size = 8192  # 8 KB

        with open(zip_file, "wb") as f, tqdm(
                desc="Downloading FLIP data",
                total=total_size,
                unit='iB',
                unit_scale=True,
                unit_divisor=1024,
        ) as progress_bar:
            for data in response.iter_content(block_size):
                size = f.write(data)
                progress_bar.update(size)

        logger.info("Unpacking FLIP data archive..")
        shutil.unpack_archive(zip_file, flip_data_dir)

        # Remove the zip file after successful extraction
        zip_file.unlink()

        logger.info("FLIP data downloaded and unpacked successfully!")

    except requests.RequestException as e:
        logger.error(f"Error downloading FLIP data: {e}")
        if zip_file.exists():
            zip_file.unlink()
        raise

    except shutil.ReadError as e:
        logger.error(f"Error unpacking FLIP data: {e}")
        if zip_file.exists():
            zip_file.unlink()
        raise

    except Exception as e:
        logger.error(f"Unexpected error while retrieving FLIP data: {e}")
        if zip_file.exists():
            zip_file.unlink()
        raise
