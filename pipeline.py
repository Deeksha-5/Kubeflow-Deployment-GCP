import kfp
client = kfp.Client()
experiment = client.create_experiment(
    name="EXP_NAME")

run_name = "RUN"
pipeline_filename = 'PIPE_FILE'
run_result = client.run_pipeline(
    experiment.id,
    run_name,
    pipeline_filename,
    params={
        'project_id': 'PROJECT_ID',
        'key_path': 'KEY_PATH',
        'bucket_path': 'BUCKET_PATH',
        'dataset': 'DATASET_NAME',
        'model': 'MODEL_NAME',
        'node_hours': 'NODE_HOURS'
    }
)
print(run_result)