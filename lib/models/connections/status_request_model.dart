import 'failure_model.dart';

enum StatusRequest { NONE, LOADING, SUCCESS, EMPTY, ERROR }

class StatusRequestModel<T> {
  StatusRequest statusRequest = StatusRequest.NONE;
  T? data;
  FailureModel? failure;

  StatusRequestModel(
      {this.statusRequest = StatusRequest.NONE, this.data, this.failure});

  StatusRequestModel.loading() {
    statusRequest = StatusRequest.LOADING;
    data = null;
    failure = null;
  }

  StatusRequestModel.success(T? newData) {
    statusRequest = StatusRequest.SUCCESS;
    data = newData;
    failure = null;
  }

  StatusRequestModel.empty() {
    statusRequest = StatusRequest.EMPTY;
    data = null;
    failure = null;
  }

  StatusRequestModel.error(FailureModel? error) {
    statusRequest = StatusRequest.ERROR;
    data = null;
    failure = error;
  }
}
