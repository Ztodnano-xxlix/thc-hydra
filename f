import json
import boto3

session = boto3.Session(aws_access_key_id=<your_access_key_id>,
    aws_secret_access_key=<your_aws_secret_access_key>)

adx = session.client(
    'dataexchange',
    region_name='us-east-1'
)

def get_api_response(path, method="GET", querystring={}, headers={}, body={}):
    return adx.send_api_asset(
        DataSetId=<data_set_id>,
        RevisionId=<revision_id>,
        AssetId=<asset_id>,
        Method=method,
        Path=path,
        QueryStringParameters=querystring,
        RequestHeaders=headers,
        Body=json.dumps(body),
    )

query = {
    "market_venue": "binance",
    "symbol": "btc",
    "base": "usdt",
    "start": "2022-04-08T00:00:00",
    "end": "2022-05-09T00:00:00",
    "gran": "1d"
}

headers = {"Accept": "application/json"}
res = get_api_response(path="metrics/ohlcv", querystring=query, headers=headers)
print(res["Body"])

Status codes

    200 OK - the request was valid and successfully processed
    200 - The output was truncated. The payload exceeded the 10000 events. Time period covered: {timestamp} - {timestamp}.
    403 - missing, incorrect or expired credentials (AWS Signature is time sensitive)
    429 - user exceeded his quota or rate limit
    400 - the user did not build the request correctly
        any of the required parameter was not specified (market_venue, symbol, base, start) - response sample message: {"message": "Missing required request parameters: [market_venue]"}
        the specified market is not supported (market_venue, symbolor base) - response sample message: {"message": "Incorrect request. The specified asset is not supported. Please check the list of supported markets (metadata endpoint)."}
        incorrect format for start and/or end parameters (invalid examples: 2022-03-05 10:05:00, 2022-02-20T30:00:00, 2022-02-20T00:00:00.000) - response sample message: {"message": "Incorrect request. Argument 'start' should be provided in the format %Y-%m-%dT%H:%M:%S (example: 2021-01-01T00:00:00)."}
        end timestamp is earlier than start timestamp - example: start=2022-02-20T00:00:00, end=2022-02-11T00:00:00 - response sample message: {"message": "Incorrect request. End timestamp should be later than start timestamp."}
        the incorrect ratio of the specified granularity and time period - reference the depth of request above. {"message": "Incorrect request. Check ratio of granularity and time period."}
    403 - Missing, incorrect or expired credentials
    429 - The rate limit is exceeded
    500 - something wrong happened on our side - example: AWS service outages
