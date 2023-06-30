# 0. 패키지 설치 및 환경 설정

## 필수 패키지 설치
install.packages("tidyverse")
install.packages("tidymodels")

# 유틸리티
install.packages("tictoc")
install.packages("doParallel")
install.packages("furrr")
install.packages("xgboost")

# 대응 알고리즘 - 대조군
install.packages("ranger")
install.packages("glmnet")

#  데이터셋
install.packages("palmerpenguins")

# 테마
install.packages("hrbrthemes")

### 결과 확인용
install.packages("finetune")


## 패키지 불러오기
library(tidyverse)
library(tidymodels)
library(tictoc)
library(doParallel)
library(furrr)
library(ranger)
library(glmnet)
library(palmerpenguins)
library(hrbrthemes)
hrbrthemes::import_roboto_condensed() 
library(finetune)


##  환경 설정
theme_set(hrbrthemes::theme_ipsum_rc())
plan(multicore, workers = availableCores())  
cores <- parallel::detectCores(logical = FALSE)
cl <- makePSOCKcluster(cores)
registerDoParallel(cores = cl)
set.seed(42)

# 1. 데이터 불러오기 및 전처리
penguins_data <- palmerpenguins::penguins
penguins_data  # NA가 있는 것을 확인함.
t(map_df(penguins_data, ~sum(is.na(.))))

penguins_df <-
  penguins_data %>%
  filter(!is.na(sex)) %>% # 성별에 na가 없으면 좋겠어!
  select(-year, -island)
head(penguins_df)


penguins_split <-
  rsample::initial_split(  # initial_split: 원본 데이터를 가지고 split 할 거얌.
    penguins_df,
    prop = 0.7,
    strata = species
  )

## 2. 베이스라인 구축 - 1차 모델(원형 모델)



tic(" Baseline XGBoost training duration ")
xgboost_fit <-
  boost_tree() %>%
  set_engine("xgboost") %>%  # 알고리즘은 방식은 xgboost을 사용해줘~ / xgboost를  설치해야 함.
  set_mode("classification") %>%  
  fit(species ~ ., data = training(penguins_split)) 
toc(log = TRUE)

preds <- predict(xgboost_fit, new_data = testing(penguins_split))
actual <- testing(penguins_split) %>% select(species)
yardstick::f_meas_vec(truth = actual$species, estimate = preds$.pred_class)


## 3. 모델 설정
# 머신러닝 먼저하고 딥러닝을 하는 것을 선호 / cpu를 갈고 그 결과를 가지고 딥러닝으로 간다.
ranger_model <-
  parsnip::rand_forest(mtry = tune(), min_n = tune()) %>%  # tune(): 이제부터 튜닝할겡
  set_engine("ranger") %>%  # 알고리즘에 따라 들어가는 특성이 다름.
  set_mode("classification")

glm_model <-
  parsnip::multinom_reg(penalty = tune(), mixture = tune()) %>%
  set_engine("glmnet") %>%
  set_mode("classification")

xgboost_model <-
  parsnip::boost_tree(mtry = tune(), learn_rate = tune()) %>%
  set_engine("xgboost") %>%
  set_mode("classification")

hardhat::extract_parameter_dials(glm_model, "mixture")

## 4. Grid 검색
ranger_grid <-
  hardhat::extract_parameter_set_dials(ranger_model) %>%
  finalize(select(training(penguins_split), -species)) %>%
  grid_regular(levels = 4)
ranger_grid

ranger_grid %>%
  ggplot(aes(mtry, min_n)) +
  geom_point(size = 4, alpha = 0.6) +
  labs(title = "Ranger: Regular grid for min_n & mtry combinations")

glm_grid <-
  parameters(glm_model) %>%
  grid_random(size = 20)
glm_grid

glm_grid %>% ggplot(aes(penalty, mixture)) +
  geom_point(size = 4, alpha = 0.6) +
  labs(title = "GLM: Random grid for penalty & mixture combinations")

xgboost_grid <-
  parameters(xgboost_model) %>%
  finalize(select(training(penguins_split), -species)) %>%
  grid_max_entropy(size = 20)
xgboost_grid

xgboost_grid %>% ggplot(aes(mtry, learn_rate)) +
  geom_point(size = 4, alpha = 0.6) +
  labs(title = "XGBoost: Max Entropy grid for LR & mtry combinations")

# 5. 1차 데이터 전처리
recipe_base <-
  recipe(species ~ ., data = training(penguins_split)) %>%
  step_dummy(all_nominal(), -all_outcomes(), one_hot = TRUE) # Create dummy variables (which glmnet neerecipe_1 <-

recipe_1 <-
  recipe_base %>%
  step_YeoJohnson(all_numeric())

recipe_1 %>%
  prep() %>%
  juice() %>%
  summary()


recipe_2 <-
  recipe_base %>%
  step_normalize(all_numeric())
recipe_2 %>%
  prep() %>%
  juice() %>%
  summary()

# 6. 일괄처리 정의
model_metrics <- yardstick::metric_set(f_meas, pr_auc)

# k겹 교차를 써야 데이터에 공신력이 생김.
data_penguins_3_cv_folds <-
  rsample::vfold_cv(
    v = 5,
    data = training(penguins_split),
    strata = species
  )

ranger_r1_workflow <-
  workflows::workflow() %>%
  add_model(ranger_model) %>%
  add_recipe(recipe_1)

glm_r2_workflow <-
  workflows::workflow() %>%
  add_model(glm_model) %>%
  add_recipe(recipe_2) 

xgboost_r2_workflow <-
  workflows::workflow() %>%
add_model(xgboost_model) %>%
  add_recipe(recipe_2)  # recipe_2 사용: 숫자로만 바꾼 값을 사용한다는 의미

## 그리드 서치 시작
tic("Ranger tune grid training duration ")
ranger_tuned <-
  tune::tune_grid(
    object = ranger_r1_workflow,  # 왜 에러나지?
    resamples = data_penguins_3_cv_folds,
    grid = ranger_grid,
    metrics = model_metrics,
    control = tune::control_grid(save_pred = TRUE)
  )
toc(log = TRUE)

tic("GLM tune grid training duration ")
glm_tuned <-
  tune::tune_grid(
    object = glm_r2_workflow,
    resamples = data_penguins_3_cv_folds,
    grid = glm_grid,
    metrics = model_metrics,
    control = tune::control_grid(save_pred = TRUE)
  )
toc(log = TRUE)

tic("XGBoost tune grid training duration ")
xgboost_tuned <-
  tune::tune_grid(
    object = xgboost_r2_workflow,
    resamples = data_penguins_3_cv_folds,
    grid = xgboost_grid,
    metrics = model_metrics,
    control = tune::control_grid(save_pred = TRUE)
  )
toc(log = TRUE)

# 8. 결과 확인
tic("Tune race training duration ")
ft_xgboost_tuned <-
  finetune::tune_race_anova(
    object = xgboost_r2_workflow,
    resamples = data_penguins_3_cv_folds,
    grid = xgboost_grid,
    metrics = model_metrics,
    control = control_race(verbose_elim = TRUE) # 66
  )
toc(log = TRUE)

plot_race(ft_xgboost_tuned) +
  labs(title = "Parameters Race by Fold")

