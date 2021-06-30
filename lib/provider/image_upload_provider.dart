import 'package:flutter/material.dart';
import 'package:skype/enum/view_state.dart';

class ImageUploadProvider with ChangeNotifier {
  ViewState _viewState = ViewState.IDLE;
  get getViewState => _viewState;

  void setLoading() {
    _viewState = ViewState.LOADING;
    notifyListeners();
  }

  void setIdle() {
    _viewState = ViewState.IDLE;
    notifyListeners();
  }
}
