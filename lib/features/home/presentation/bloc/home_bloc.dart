import 'package:bloc/bloc.dart';

import '../../../../domain/domain/entities/youtube_video_entity.dart';
import '../../../../domain/domain/usecases/get_video_usecase.dart';
import '../../../../shared_libraries/common/utils/error/failure_response.dart';
import '../../../../shared_libraries/common/utils/state/view_data_state.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetVideoUseCase getVideoUseCase;

  HomeBloc({
    required this.getVideoUseCase,
  }) : super(HomeState(statusYouTubeVideo: ViewData.initial())) {
    on<HomeEvent>(_onEvent);
  }

  _onEvent(HomeEvent event, Emitter<HomeState> emit) async {
    if (event is SearchVideo) {
      await _searchVideo(event.query, emit);
    }
  }

  Future<void> _searchVideo(String query, Emitter<HomeState> emit) async {
    emit(state.copyWith(
        statusYouTubeVideo: ViewData.loading(message: 'Loading')));

    final newState = await getVideoUseCase.call(query).then((value) =>
        value.fold((l) => _failureState(l), (r) => _successState(r)));
    emit(newState);
  }

  HomeState _failureState(FailureResponse failure) {
    return state.copyWith(
        statusYouTubeVideo: ViewData.error(
      message: failure.errorMessage,
      failure: failure,
    ));
  }

  HomeState _successState(
    YouTubeVideoEntity? data,
  ) {
    final videos = data?.items ?? [];
    if (videos.isEmpty) {
      return state.copyWith(
        statusYouTubeVideo: ViewData.noData(message: 'No Data'),
      );
    } else {
      return state.copyWith(statusYouTubeVideo: ViewData.loaded(data: data));
    }
  }
}