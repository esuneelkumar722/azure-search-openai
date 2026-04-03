output "principal_id" { value = azurerm_linux_function_app.document_extractor.identity[0].principal_id }
output "document_extractor_url" { value = azurerm_linux_function_app.document_extractor.default_hostname }
output "figure_processor_url" { value = azurerm_linux_function_app.figure_processor.default_hostname }
output "text_processor_url" { value = azurerm_linux_function_app.text_processor.default_hostname }
