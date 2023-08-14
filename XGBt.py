from sklearn.model_selection import RandomizedSearchCV,GridSearchCV
from sklearn.model_selection import train_test_split,cross_val_score	
from sklearn.metrics import mean_squared_error
import xgboost as xgb
from xgboost import plot_importance
import warnings
warnings.filterwarnings("ignore")


def XGfix(X_train,y_train,X_test,y_test):
   
    model=xgb.XGBRegressor(objective='reg:squarederror',eval_metric='rmse',random_state=8)
    change_params = {'n_estimators': range(1, 20,2),
                    #              'max_features':range(1, 7, 2)
                    #              'learning_rate':[0.01,0.1,0.5],
                                    'max_depth': range(1, 7, 3)
                    #              'min_samples_split': range(3, 10, 2),
}

    rf_bst=GridSearchCV(model,change_params,scoring='neg_mean_squared_error',cv=5)
    rf_bst.fit(X_train,y_train)
  #  print('GridSearchCV_best_score:',rf_bst.best_score_)
  #  print('GridSearchCV_best_params：',rf_bst.best_params_)
  #  print('GridSearchCV_best_model：',rf_bst.best_estimator_)
    y_pre=rf_bst.predict(X_test)
    score=mean_squared_error(y_test,y_pre)
    result={'y_pre':y_pre,'score':score}
    return result

