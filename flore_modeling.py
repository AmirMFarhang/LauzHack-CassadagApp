import pandas as pd
import numpy as np
from prophet import Prophet
import pickle


def load_and_prepare_data(filepath, date_col, target_col, regressors):
    df = pd.read_csv(filepath, sep=',')
    df = df.fillna(0)
    df[date_col] = pd.to_datetime(df[date_col])
    df = df.sort_values(date_col)
    df = df.rename({date_col: 'ds', target_col: 'y'}, axis='columns')

    df_filtered = df[regressors].copy()
    df_filtered['ds'] = df['ds']
    df_filtered['y'] = df['y']

    split_ratio = 0.8
    split_index = int(len(df_filtered) * split_ratio)

    train_df = df_filtered.iloc[:split_index]
    test_df = df_filtered.iloc[split_index:]
    return train_df, test_df


def create_and_fit_model(train_df, regressors):
    m = Prophet(interval_width=0.99)

    for regressor in regressors:
        m.add_regressor(regressor)

    m.fit(train_df)
    return m


def create_forecast_test(model, test_df):
    forecast = model.predict(test_df)
    forecast_complete = forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper']]
    return forecast, forecast_complete


def create_forecast(model, regressors, start, end, fixed_regressors=None, default_value=0):
    future_dates = pd.date_range(start=start, end=end, freq='MS')
    future_df = pd.DataFrame({'ds': future_dates})

    for regressor in regressors:
        if fixed_regressors and regressor in fixed_regressors:
            future_df[regressor] = fixed_regressors[regressor]  # Usa il valore specifico
        else:
            future_df[regressor] = default_value  # Usa il valore predefinito

    forecast = model.predict(future_df)
    forecast_complete = forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper', 'additive_terms', 'extra_regressors_additive'] + regressors]
    return forecast, forecast_complete

def assess_regressor_impact(forecast):
    local_regressor_impact = forecast[['ds', 'additive_terms', 'extra_regressors_additive']]
    local_regressor_dict = {}
    for index, line in local_regressor_impact.iterrows():
        ds = line["ds"]
        additive_terms = line["additive_terms"]
        extra_regressors_additive = line["extra_regressors_additive"]
        if additive_terms > extra_regressors_additive:
            local_regressor_dict[ds] = "trend"
        else:
            local_regressor_dict[ds] = "external regressors"
    return local_regressor_dict


def mean_absolute_percentage_error(y_true, y_pred):
    y_true, y_pred = np.array(y_true), np.array(y_pred)
    return np.mean(np.abs((y_true - y_pred) / y_true)) * 100


if __name__ == "__main__":

    FILEPATH = 'df_inno_flore1.csv'
    DATE_COLUMN = 'Date'
    TARGET_COLUMN = 'Ex-factory volumes'
    REGRESSORS = ['INNOVIX_Indication 10_Email',
 'INNOVIX_Indication 10_Face to face call',
 'INNOVIX_Indication 10_Remote call',
 'INNOVIX_Indication 12_Email',
 'INNOVIX_Indication 12_Face to face call',
 'INNOVIX_Indication 12_Meetings',
 'INNOVIX_Indication 12_Remote call',
 'INNOVIX_Indication 19_Email',
 'INNOVIX_Indication 1_Remote call',
 'INNOVIX_Indication 12_Indication 12_New patient share',
 'INNOVIX_Indication 2_Indication 2-b_New patient share',
 'YREX_Indication 10']


    train_df, test_df = load_and_prepare_data(FILEPATH, DATE_COLUMN, TARGET_COLUMN, REGRESSORS)

    model = create_and_fit_model(train_df, REGRESSORS)

    forecast, forecast_complete = create_forecast_test(model, test_df)

    mape = mean_absolute_percentage_error(test_df['y'], forecast['yhat'])
    print(f"Accuracy: {(100 - mape):.2f}%")

    local_impact = assess_regressor_impact(forecast)
    print("Regressor Impact Analysis:")
    print(local_impact)

    fixed_values = {
    'INNOVIX_Indication 10_Email': 10,
    'YREX_Indication 10': 5
}
    forecast, forecast_complete = create_forecast(model, REGRESSORS, "2025-12-31", "2027-12-31",
    fixed_regressors=fixed_values,
    default_value=0)
    print(forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper']])

    with open('prophet_model_flore.pkl', 'wb') as f:
        pickle.dump(model, f)
