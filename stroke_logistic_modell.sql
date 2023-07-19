--truy cập dữ liệu
SELECT *
FROM `project-binh-2023-demo.DA04.healthcare-dataset-stroke`
LIMIT 10;
--Thông tin cột “stroke” cho thấy dữ liệu bị mất cân bằng, trong đó khoảng 5% dữ liệulà bệnh nhân có khả năng bị đột quỵ (dùng auto_class_weights=TRUE để giải quyết)

#standarkSQL
--build model để dự đoán 
CREATE OR REPLACE MODEL `DA04.stroke_model`
OPTIONS( model_type = 'LOGISTIC_REG',
       auto_class_weights= TRUE,
       input_label_cols= ['stroke']
     ) AS
SELECT 
   gender, age, hypertension, heart_disease, ever_married, work_type, avg_glucose_level, bmi, smoking_status, stroke
FROM
   `project-binh-2023-demo.DA04.healthcare-dataset-stroke`;
--result after run
Aggregate Metrics
Threshold  0.5000
Precision  0.1597
Recall     0.4318
Accuracy   0.8713
F1 score   0.2331
Log loss   0.2990
ROC AUC    0.7760
--If we focus on identifying patients at risk of stroke, this model can be used temporarily, but we expect better results. It could be achieved by trying different algorithms.
--Let's reevaluate the model once again.

SELECT
*
FROM
ML.EVALUATE(MODEL `DA04.stroke_model`,
 (
  SELECT gender, age, hypertension, heart_disease, ever_married, work_type, avg_glucose_level, bmi, smoking_status, stroke
  FROM `project-binh-2023-demo.DA04.healthcare-dataset-stroke`
 ));
---result
precision	        recall	                accuracy	         f1_score	        log_loss	          roc_auc
0.25993883792048927	0.68273092369477917	0.88982387475538161	0.37652270210409744	0.25746286954500142	0.90425574425574429

Precision: 0.2599
Precision measures the proportion of true positive predictions among all positive predictions. In this case, the model correctly identifies approximately 26% of the patients at risk of stroke among all predicted positive cases.

Recall: 0.6827
Recall, also known as sensitivity or true positive rate, measures the proportion of true positive predictions among all actual positive cases. The model is able to capture about 68% of the actual patients at risk of stroke.

Accuracy: 0.8898
Accuracy measures the overall proportion of correct predictions among all predictions made by the model. The model achieves approximately 89% accuracy, which is the percentage of correct predictions over the entire dataset.

F1 Score: 0.3765
The F1 score is the harmonic mean of precision and recall. It provides a balanced measure between precision and recall. In this case, the F1 score is around 38%, indicating that the model has some balance between precision and recall.

Log Loss: 0.2575
Log Loss (cross-entropy loss) measures the dissimilarity between predicted probabilities and the actual labels. A lower log loss indicates that the model's predicted probabilities are closer to the true labels.

ROC AUC: 0.904
ROC AUC (Receiver Operating Characteristic Area Under the Curve) measures the model's ability to distinguish between positive and negative classes. A higher ROC AUC value (close to 1) indicates better discrimination.
In summary, the model shows relatively good performance in terms of accuracy and ROC AUC, but there is still room for improvement in precision and recall. Depending on the specific requirements and objectives, further optimization of the model or exploration of different algorithms may be considered to achieve better results in identifying patients at risk of stroke.

-- Make a new prediction with specific information.
--gender: Male
--age:26
--hypertension: 0
--heart_diease:0
--ever_maried: False
--work_type: Priviate
--avg_glucose_level: 143.33
--bmi: 22.4
--smiking_status: formerly smoked


SELECT *
FROM ML.PREDICT (MODEL `DA04.stroke_model`,(
   SELECT "Male" as gender,
   26 as age,
   0 as hypertension,
   0 as heart_disease,
   False as ever_married,
   "Private" as work_type,
   143.33 as avg_glucose_level,
   CAST(22.4 AS STRING) as bmi,
   "formerly smoked" as smoking_status
))

--result
predict_stroke  predicted_stroke_probs.label   predicted_stroke_probs.prob

 0                     1                             0.13010629800654208
                       0                             0.869893701993458


Based on the provided prediction result, the patient is predicted to not have a stroke (predicted_stroke=0). The predicted_stroke_probs indicate the probability for each class label, where the probability of having a stroke (predicted_stroke=1) is approximately 0.1301, and the probability of not having a stroke (predicted_stroke=0) is approximately 0.8699.
