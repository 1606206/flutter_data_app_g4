library(lubridate)
# Generar fechas 
fechas <- seq(Sys.Date() - days(90), by = "days", length.out = 90)

# Generar datos aleatorios de clientes para cada fecha
clientes_diarios <- sample(0:100, length(fechas), replace = TRUE)  

# Crear un dataframe
datos <- data.frame(fecha = fechas, clientes = clientes_diarios)

# Guardar como JSON
library(jsonlite)
json_data <- toJSON(datos, pretty = TRUE)
writeLines(json_data, "clientes_diarios.json")

library(prophet)
fechas_prediccion <- seq(max(datos$fecha) + days(1), max(datos$fecha) + days(30), by = "days")

# Crear un dataframe para prophet
df_prophet <- data.frame(ds = datos$fecha, y = datos$clientes)

# Ajustar el modelo prophet
modelo_prophet <- prophet(df_prophet)

# Crear un dataframe para las fechas de predicción
df_prediccion_prophet <- data.frame(ds = fechas_prediccion)

# Realizar las predicciones
predicciones_prophet <- predict(modelo_prophet, df_prediccion_prophet)
predicciones_fin <- round(predicciones_prophet$yhat)
print(predicciones_fin)

# Añadir las predicciones al dataframe original
df_predicciones_prophet <- data.frame(fecha = fechas_prediccion, clientes = predicciones_fin)
datos_completos_prophet <- rbind(datos, df_predicciones_prophet)

#Guardamos predicciones
json_data <- toJSON(df_predicciones_prophet, pretty = TRUE)
writeLines(json_data, "clientes_prediccion.json")

# Guardar el dataframe completo, datos + predicciones
json_data_completo_prophet <- toJSON(datos_completos_prophet, pretty = TRUE)
writeLines(json_data_completo_prophet, "clientes_diarios_con_predicciones_prophet.json")
