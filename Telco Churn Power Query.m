let
    Source = Csv.Document(
        File.Contents("D:\\PROJECTS\\Telco-Customer-Churn-PowerBI\\Telco-Customer-Churn.csv"),
        [Delimiter = ",", Columns = 21, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    #"Set Source Types" = Table.TransformColumnTypes(
        #"Promoted Headers",
        {
            {"customerID", type text},
            {"gender", type text},
            {"SeniorCitizen", Int64.Type},
            {"Partner", type text},
            {"Dependents", type text},
            {"tenure", Int64.Type},
            {"PhoneService", type text},
            {"MultipleLines", type text},
            {"InternetService", type text},
            {"OnlineSecurity", type text},
            {"OnlineBackup", type text},
            {"DeviceProtection", type text},
            {"TechSupport", type text},
            {"StreamingTV", type text},
            {"StreamingMovies", type text},
            {"Contract", type text},
            {"PaperlessBilling", type text},
            {"PaymentMethod", type text},
            {"MonthlyCharges", Currency.Type},
            {"TotalCharges", type text},
            {"Churn", type text}
        },
        "en-US"
    ),
    #"Added Clean TotalCharges" = Table.AddColumn(
        #"Set Source Types",
        "TotalCharges Clean",
        each
            if [tenure] = 0 and ([TotalCharges] = null or Text.Trim([TotalCharges]) = "") then
                0
            else
                Number.FromText(Text.Trim([TotalCharges]), "en-US"),
        Currency.Type
    ),
    #"Removed Raw TotalCharges" = Table.RemoveColumns(#"Added Clean TotalCharges", {"TotalCharges"}),
    #"Renamed Clean TotalCharges" = Table.RenameColumns(
        #"Removed Raw TotalCharges",
        {{"TotalCharges Clean", "TotalCharges"}}
    ),
    #"Changed SeniorCitizen Labels" = Table.TransformColumns(
        #"Renamed Clean TotalCharges",
        {
            {
                "SeniorCitizen",
                each if _ = 0 then "No" else if _ = 1 then "Yes" else null,
                type text
            }
        }
    ),
    #"Added Churn Flag" = Table.AddColumn(
        #"Changed SeniorCitizen Labels",
        "Churn Flag",
        each if [Churn] = "Yes" then 1 else if [Churn] = "No" then 0 else null,
        Int64.Type
    ),
    #"Added Tenure Band" = Table.AddColumn(
        #"Added Churn Flag",
        "Tenure Band",
        each
            if [tenure] < 0 or [tenure] > 72 then "Out of range"
            else if [tenure] <= 12 then "0-12"
            else if [tenure] <= 24 then "13-24"
            else if [tenure] <= 48 then "25-48"
            else "49-72",
        type text
    ),
    #"Added Monthly Charge Band" = Table.AddColumn(
        #"Added Tenure Band",
        "Monthly Charge Band",
        each
            if [MonthlyCharges] = null then null
            else if [MonthlyCharges] < 35 then "Low"
            else if [MonthlyCharges] < 70 then "Medium"
            else "High",
        type text
    ),
    #"Reordered Columns" = Table.ReorderColumns(
        #"Added Monthly Charge Band",
        {
            "customerID", "gender", "SeniorCitizen", "Partner", "Dependents", "tenure",
            "Tenure Band", "PhoneService", "MultipleLines", "InternetService", "OnlineSecurity",
            "OnlineBackup", "DeviceProtection", "TechSupport", "StreamingTV", "StreamingMovies",
            "Contract", "PaperlessBilling", "PaymentMethod", "MonthlyCharges",
            "Monthly Charge Band", "TotalCharges", "Churn", "Churn Flag"
        }
    )
in
    #"Reordered Columns"
