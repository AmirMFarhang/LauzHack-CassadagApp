import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
from prophet import Prophet
from prophet.diagnostics import cross_validation, performance_metrics
from prophet.utilities import regressor_coefficients


def load_and_prepare_data(filepath, date_col, target_col, regressors):
    df = pd.read_csv(filepath, sep=',')
    df = df.fillna(0)
    df[date_col] = pd.to_datetime(df[date_col])
    df = df.sort_values(date_col)
    df = df.rename({date_col: 'ds', target_col: 'y'}, axis='columns')

    df_filtered = df[regressors].copy()
    df_filtered['ds'] = df['ds']
    df_filtered['y'] = df['y']
    return df, df_filtered


def create_and_fit_model(df_filtered, regressors):
    model = Prophet(interval_width=0.99)
    for regressor in regressors:
        model.add_regressor(regressor)
    model.fit(df_filtered)
    return model


def calculate_cross_validation_metrics(model):
    df_cv = cross_validation(
        model=model,
        initial='730 days',
        period='180 days',
        horizon='365 days',
        parallel="processes"
    )
    mape_baseline = mean_absolute_percentage_error(df_cv.y, df_cv.yhat)
    accurancy = 100 - mape_baseline
    return df_cv, accurancy


def create_forecast(model, regressors, start, end):
    future_dates = pd.date_range(start= start, end= end, freq='MS')
    future_df = pd.DataFrame({'ds': future_dates})
    for regressor in regressors:
        future_df[regressor] = 0  # Set to default values

    forecast = model.predict(future_df)
    forecast_complete = forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper', 'additive_terms', 'extra_regressors_additive'] + regressors]
    return forecast,forecast_complete


def assess_regressor_impact(forecast):
    local_regressor_impact = forecast[['ds', 'additive_terms', 'extra_regressors_additive']]
    local_regressor_dict = {}
    for index, line in local_regressor_impact.iterrows():
        ds = line["ds"]
        additive_terms = line["additive_terms"]
        extra_regressors_additive = line["extra_regressors_additive"]  
        if  additive_terms > extra_regressors_additive:
            local_regressor_dict[ds] = "trend"
        else:
            local_regressor_dict[ds] = "external regressors"
    return local_regressor_dict


def mean_absolute_percentage_error(y_true, y_pred):
    y_true, y_pred = np.array(y_true), np.array(y_pred)
    return np.mean(np.abs((y_true - y_pred) / y_true)) * 100


if __name__ == "__main__":

    # Define constants
    FILEPATH = 'dataset.csv'
    DATE_COLUMN = 'Date'
    TARGET_COLUMN = 'Ex-Factory volumes'
    REGRESSORS = [
        'BRISTOR_Email',
        'BRISTOR_Face to face call',
        'BRISTOR_Mail',
        'BRISTOR_Remote call',
        'BRISTOR_Telephone',
        'Competitors_Indication A_Days of Treatment',
        'BRISTOR_Indication A_New Patient #'
    ]

    # Load and prepare data
    df, df_filtered = load_and_prepare_data(FILEPATH, DATE_COLUMN, TARGET_COLUMN, REGRESSORS)

    # Create and fit model
    model = create_and_fit_model(df_filtered, REGRESSORS)

    # Calculate cross-validation metrics
    df_cv, performance_df = calculate_cross_validation_metrics(model)

    # Create forecast
    forecast, forecast_complete = create_forecast(model, REGRESSORS, "2024-12-31", "2025-12-31")
    print(forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper']])

    # Assess regressor impact
    local_impact = assess_regressor_impact(forecast)
    print(local_impact)

   # Maybe also extract the most influential regressor
