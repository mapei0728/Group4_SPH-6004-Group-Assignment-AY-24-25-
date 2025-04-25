library(tidyverse)
library(ggplot2)
library(tidyr)

data <- tribble(
  ~Label, ~Class, ~Percent,
  "Enlarged Cardiomediastinum", "Absent", 67.88,
  "Enlarged Cardiomediastinum", "Present", 8.83,
  "Enlarged Cardiomediastinum", "Missing", 23.29,
  
  "Cardiomegaly", "Absent", 70.82,
  "Cardiomegaly", "Present", 8.17,
  "Cardiomegaly", "Missing", 21.01,
  
  "Lung Opacity", "Absent", 70.82,
  "Lung Opacity", "Present", 1.78,
  "Lung Opacity", "Missing", 27.40,
  
  "Lung Lesion", "Absent", 73.65,
  "Lung Lesion", "Present", 2.54,
  "Lung Lesion", "Missing", 23.81,
  
  "Edema", "Absent", 69.07,
  "Edema", "Present", 1.51,
  "Edema", "Missing", 29.41,
  
  "Consolidation", "Absent", 67.90,
  "Consolidation", "Present", 2.16,
  "Consolidation", "Missing", 29.94,
  
  "Pneumonia", "Absent", 68.03,
  "Pneumonia", "Present", 2.88,
  "Pneumonia", "Missing", 29.09,
  
  "Atelectasis", "Absent", 68.36,
  "Atelectasis", "Present", 11.80,
  "Atelectasis", "Missing", 19.84,
  
  "Pneumothorax", "Absent", 73.23,
  "Pneumothorax", "Present", 8.14,
  "Pneumothorax", "Missing", 18.63,
  
  "Pleural Effusion", "Absent", 67.69,
  "Pleural Effusion", "Present", 1.05,
  "Pleural Effusion", "Missing", 31.26,
  
  "Pleural Other", "Absent", 73.08,
  "Pleural Other", "Present", 4.78,
  "Pleural Other", "Missing", 22.14,
  
  "Fracture", "Absent", 73.69,
  "Fracture", "Present", 1.25,
  "Fracture", "Missing", 25.06,
  
  "Support Devices", "Absent", 68.33,
  "Support Devices", "Present", 4.31,
  "Support Devices", "Missing", 27.37
)

#data$Label <- factor(data$Label, levels = paste("Label", 0:12))

# data <- data %>%
#   group_by(Label) %>%
#   mutate(pos = cumsum(Percent) - Percent / 2)

data$Class <- factor(data$Class, levels = c("Present", "Absent", "Missing"))

ggplot(data, aes(x = Label, y = Percent, fill = Class)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = paste0(Percent,"%")), position = position_stack(vjust = 0.5), size = 3) +
  coord_flip() +
  scale_fill_manual(values = c("Absent" = "#1f78b4", "Present" = "#33a02c", "Missing" = "#b2b2b2")) +
  labs(
    title = "Class Distribution per lung condition",
    x = "Lung Condition",
    y = "Percentage",
    fill = "Class"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10),
    plot.title = element_text(size = 14, face = "bold"),
    legend.position = "bottom"
  )

# ggplot(data, aes(x = Label, y = Percent, fill = Class)) +
#   geom_bar(stat = "identity") +
#   geom_text(aes(label = paste0(Percent, "%"), y = pos), size = 3, colour = "white") +
#   coord_flip() +
#   scale_fill_manual(values = c("Absent" = "#1f78b4", "Present" = "#33a02c", "Missing" = "#b2b2b2")) +
#   labs(
#     title = "Class Distribution per lung condition",
#     x = "Lung condition",
#     y = "Percentage",
#     fill = "Class"
#   ) +
#   theme_minimal() +
#   theme(
#     axis.text.y = element_text(size = 10),
#     axis.text.x = element_text(size = 10),
#     plot.title = element_text(size = 14, face = "bold")
#   )


rm(data); gc()

aps <- as.data.frame(read.csv("Average_Precision_Score.csv"))
aps <- aps[-11,]
label_names <- c("Enlarged Cardiomediastinum","Cardiomegaly","Lung Opacity",
                   "Lung Lesion","Edema","Consolidation","Pneumonia","Atelectasis",
                   "Pneumothorax","Pleural Effusion","Pleural Other","Fracture",
                   "Support Devices")
colnames(aps) <- c("Methods", paste0("Label_",seq(0,12)))
aps$MethodType = c("Task 1: LightGBM", "Task 1: LightGBM", "Task 1: MLP", 
                   "Task 1: MLP", "Task 1: MLP", "Task 1: MLP", 
                   "Task 1: Transformer","Task 1: Transformer","Task 1: Transformer",
                   "Task 1: Transformer",
                   "Task 1: LightGBM","Task 1: MLP","Task 1: Transformer","Task 2", "Task 3")

df_long <- pivot_longer(aps, cols = starts_with("Label"), 
                        names_to = "Label", values_to = "AvgPrecision")
df_long$Condition <- rep(label_names,15)

method_type_order <- c("Task 1: LightGBM", "Task 1: MLP", "Task 1: Transformer","Task 2", "Task 3")
method_order <- c("LGBM (SMOTE) 100D", "LGBM (SMOTE)", "LGBM",
                  "Simple MLP (Weight) 100D","Simple MLP (SMOTE)", 
                  "Simple MLP (Weight)","Multilayer MLP", 
                  "Simple MLP", 
                  "TabTransformer (ASL) 100D",
                  "TabTransformer (ASL+Grid+GEGLU)","TabTransformer (ASL+Grid)", 
                  "TabTransformer (ASL)","TabTransformer (FocalL)", 
                  "NLP", "MultiModal")

df_long$Methods<- factor(df_long$Methods, levels = method_order)
df_long$MethodType <- factor(df_long$MethodType, levels = method_type_order)



ggplot(df_long, aes(x = Condition, y = Methods, fill = AvgPrecision)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "deeppink2", limits = c(0,1)) +
  geom_text(aes(label = round(AvgPrecision, 2))) +
  facet_grid(MethodType ~ ., scales = "free_y", space = "free_y") +
  theme_minimal() +
  theme(
    strip.text.y = element_text(angle = 0, hjust = 0),
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10),
    axis.text.x = element_text(angle = 90), 
    #legend.position = "bottom"
  ) +
  labs(x = "", y = "", fill = "Average\nPrecision\nScores")


####precision
presicion <- as.data.frame(read.csv("Precision_Final.csv"))
presicion <- presicion[-11,]
label_names <- c("Enlarged Cardiomediastinum","Cardiomegaly","Lung Opacity",
                 "Lung Lesion","Edema","Consolidation","Pneumonia","Atelectasis",
                 "Pneumothorax","Pleural Effusion","Pleural Other","Fracture",
                 "Support Devices")
colnames(presicion) <- c("Methods", paste0("Label_",seq(0,12)))
presicion$MethodType = c("Task 1: LightGBM", "Task 1: LightGBM", "Task 1: MLP", 
                   "Task 1: MLP", "Task 1: MLP", "Task 1: MLP", 
                   "Task 1: Transformer","Task 1: Transformer","Task 1: Transformer",
                   "Task 1: Transformer",
                   "Task 1: LightGBM","Task 1: MLP","Task 1: Transformer","Task 2", "Task 3")

df_long <- pivot_longer(presicion, cols = starts_with("Label"), 
                        names_to = "Label", values_to = "Presicion")
df_long$Condition <- rep(label_names,15)

method_type_order <- c("Task 1: LightGBM", "Task 1: MLP", "Task 1: Transformer","Task 2", "Task 3")
method_order <- c("LGBM (SMOTE) 100D", "LGBM (SMOTE)", "LGBM",
                  "Simple MLP (Weight) 100D","Simple MLP (SMOTE)", 
                  "Simple MLP (Weight)","Multilayer MLP", 
                  "Simple MLP", 
                  "TabTransformer (ASL) 100D",
                  "TabTransformer (ASL+Grid+GEGLU)","TabTransformer (ASL+Grid)", 
                  "TabTransformer (ASL)","TabTransformer (FocalL)", 
                  "NLP", "MultiModal")

df_long$Methods<- factor(df_long$Methods, levels = method_order)
df_long$MethodType <- factor(df_long$MethodType, levels = method_type_order)



ggplot(df_long, aes(x = Condition, y = Methods, fill = Presicion)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "steelblue3", limits = c(0,1)) +
  geom_text(aes(label = round(Presicion, 2))) +
  facet_grid(MethodType ~ ., scales = "free_y", space = "free_y") +
  theme_minimal() +
  theme(
    strip.text.y = element_text(angle = 0, hjust = 0),
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10,angle = 90), 
    #axis.text.x = element_text(angle = 90), 
    #legend.position = "bottom"
  ) +
  labs(x = "", y = "", fill = "Precision")


####Recall
Recall <- as.data.frame(read.csv("Recall_Final.csv"))
Recall <- Recall[-11,]
label_names <- c("Enlarged Cardiomediastinum","Cardiomegaly","Lung Opacity",
                 "Lung Lesion","Edema","Consolidation","Pneumonia","Atelectasis",
                 "Pneumothorax","Pleural Effusion","Pleural Other","Fracture",
                 "Support Devices")
colnames(Recall) <- c("Methods", paste0("Label_",seq(0,12)))
Recall$MethodType = c("Task 1: LightGBM", "Task 1: LightGBM", "Task 1: MLP", 
                         "Task 1: MLP", "Task 1: MLP", "Task 1: MLP", 
                         "Task 1: Transformer","Task 1: Transformer","Task 1: Transformer",
                         "Task 1: Transformer",
                         "Task 1: LightGBM","Task 1: MLP","Task 1: Transformer","Task 2", "Task 3")

df_long <- pivot_longer(Recall, cols = starts_with("Label"), 
                        names_to = "Label", values_to = "Recall")
df_long$Condition <- rep(label_names,15)

method_type_order <- c("Task 1: LightGBM", "Task 1: MLP", "Task 1: Transformer","Task 2", "Task 3")
method_order <- c("LGBM (SMOTE) 100D", "LGBM (SMOTE)", "LGBM",
                  "Simple MLP (Weight) 100D","Simple MLP (SMOTE)", 
                  "Simple MLP (Weight)","Multilayer MLP", 
                  "Simple MLP", 
                  "TabTransformer (ASL) 100D",
                  "TabTransformer (ASL+Grid+GEGLU)","TabTransformer (ASL+Grid)", 
                  "TabTransformer (ASL)","TabTransformer (FocalL)", 
                  "NLP", "MultiModal")

df_long$Methods<- factor(df_long$Methods, levels = method_order)
df_long$MethodType <- factor(df_long$MethodType, levels = method_type_order)



ggplot(df_long, aes(x = Condition, y = Methods, fill = Recall)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "seagreen4", limits = c(0,1)) +
  geom_text(aes(label = round(Recall, 2))) +
  facet_grid(MethodType ~ ., scales = "free_y", space = "free_y") +
  theme_minimal() +
  theme(
    strip.text.y = element_text(angle = 0, hjust = 0),
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10,angle = 90), 
    #axis.text.x = element_text(angle = 90), 
    #legend.position = "bottom"
  ) +
  labs(x = "", y = "", fill = "Recall")

####F1
F1 <- as.data.frame(read.csv("F1-Score_Final.csv"))
F1 <- F1[-11,]
label_names <- c("Enlarged Cardiomediastinum","Cardiomegaly","Lung Opacity",
                 "Lung Lesion","Edema","Consolidation","Pneumonia","Atelectasis",
                 "Pneumothorax","Pleural Effusion","Pleural Other","Fracture",
                 "Support Devices")
colnames(F1) <- c("Methods", paste0("Label_",seq(0,12)))
F1$MethodType = c("Task 1: LightGBM", "Task 1: LightGBM", "Task 1: MLP", 
                      "Task 1: MLP", "Task 1: MLP", "Task 1: MLP", 
                      "Task 1: Transformer","Task 1: Transformer","Task 1: Transformer",
                      "Task 1: Transformer",
                      "Task 1: LightGBM","Task 1: MLP","Task 1: Transformer","Task 2", "Task 3")

df_long <- pivot_longer(F1, cols = starts_with("Label"), 
                        names_to = "Label", values_to = "F1")
df_long$Condition <- rep(label_names,15)

method_type_order <- c("Task 1: LightGBM", "Task 1: MLP", "Task 1: Transformer","Task 2", "Task 3")
method_order <- c("LGBM (SMOTE) 100D", "LGBM (SMOTE)", "LGBM",
                  "Simple MLP (Weight) 100D","Simple MLP (SMOTE)", 
                  "Simple MLP (Weight)","Multilayer MLP", 
                  "Simple MLP", 
                  "TabTransformer (ASL) 100D",
                  "TabTransformer (ASL+Grid+GEGLU)","TabTransformer (ASL+Grid)", 
                  "TabTransformer (ASL)","TabTransformer (FocalL)", 
                  "NLP", "MultiModal")

df_long$Methods<- factor(df_long$Methods, levels = method_order)
df_long$MethodType <- factor(df_long$MethodType, levels = method_type_order)



ggplot(df_long, aes(x = Condition, y = Methods, fill = F1)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "tomato3", limits = c(0,1)) +
  geom_text(aes(label = round(F1, 2))) +
  facet_grid(MethodType ~ ., scales = "free_y", space = "free_y") +
  theme_minimal() +
  theme(
    strip.text.y = element_text(angle = 0, hjust = 0),
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10,angle = 90), 
    #axis.text.x = element_text(angle = 90), 
    #legend.position = "bottom"
  ) +
  labs(x = "", y = "", fill = "F1-score")

####Accuracy
Accuracy <- as.data.frame(read.csv("Accuracy_Final.csv"))
Accuracy <- Accuracy[-11,]
label_names <- c("Enlarged Cardiomediastinum","Cardiomegaly","Lung Opacity",
                 "Lung Lesion","Edema","Consolidation","Pneumonia","Atelectasis",
                 "Pneumothorax","Pleural Effusion","Pleural Other","Fracture",
                 "Support Devices")
colnames(Accuracy) <- c("Methods", paste0("Label_",seq(0,12)))
Accuracy$MethodType = c("Task 1: LightGBM", "Task 1: LightGBM", "Task 1: MLP", 
                      "Task 1: MLP", "Task 1: MLP", "Task 1: MLP", 
                      "Task 1: Transformer","Task 1: Transformer","Task 1: Transformer",
                      "Task 1: Transformer",
                      "Task 1: LightGBM","Task 1: MLP","Task 1: Transformer","Task 2", "Task 3")

df_long <- pivot_longer(Accuracy, cols = starts_with("Label"), 
                        names_to = "Label", values_to = "Accuracy")
df_long$Condition <- rep(label_names,15)

method_type_order <- c("Task 1: LightGBM", "Task 1: MLP", "Task 1: Transformer","Task 2", "Task 3")
method_order <- c("LGBM (SMOTE) 100D", "LGBM (SMOTE)", "LGBM",
                  "Simple MLP (Weight) 100D","Simple MLP (SMOTE)", 
                  "Simple MLP (Weight)","Multilayer MLP", 
                  "Simple MLP", 
                  "TabTransformer (ASL) 100D",
                  "TabTransformer (ASL+Grid+GEGLU)","TabTransformer (ASL+Grid)", 
                  "TabTransformer (ASL)","TabTransformer (FocalL)", 
                  "NLP", "MultiModal")

df_long$Methods<- factor(df_long$Methods, levels = method_order)
df_long$MethodType <- factor(df_long$MethodType, levels = method_type_order)



ggplot(df_long, aes(x = Condition, y = Methods, fill = Accuracy)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "mediumpurple2", limits = c(0,1)) +
  geom_text(aes(label = round(Accuracy, 2))) +
  facet_grid(MethodType ~ ., scales = "free_y", space = "free_y") +
  theme_minimal() +
  theme(
    strip.text.y = element_text(angle = 0, hjust = 0),
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10,angle = 90), 
    #axis.text.x = element_text(angle = 90), 
    #legend.position = "bottom"
  ) +
  labs(x = "", y = "", fill = "Accuracy")
