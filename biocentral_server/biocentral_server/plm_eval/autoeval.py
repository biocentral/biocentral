import yaml

from importlib import resources


def autoeval_flow(flip_dict, model_id):
    for dataset_name, dataset_dict in flip_dict.items():
        protocol = dataset_dict['protocol']
        splits = dataset_dict['splits']

        for split in splits:
            print(split["name"])
            # Preprocess files (?)
            # Prepare config
            with resources.open_text('autoeval.configsbank', f'{dataset_name}.yml') as config_file:
                config = yaml.load(config_file, Loader=yaml.FullLoader)

            config["embedder_name"] = model_id

            for file_name, file_path in split.items():
                if file_name == "name":
                    continue
                if file_path is not None:
                    config[file_name] = file_path

            # Run Biotrainer

            # Return Test Set Metrics