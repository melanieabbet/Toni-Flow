interface Action {
  void apply(DotState state);
}

class IntensifyAction implements Action {
  void apply(DotState state) {
    if(!USE_OPACITY) {
      return;
    }
    state.transparency = Math.max(0.0, state.transparency - state.transparency * DARKEN_PERCENT);
  }
}

class ThickenAction implements Action {
  void apply(DotState state) {
    state.radius = Math.min(state.radius * GROW_FACTOR, MAX_DOT_RADIUS);
  }
}

class DistanceAction implements Action {
  float distance;
  
  DistanceAction(float distance) {
    this.distance = distance;
  }
  
  void apply(DotState state) {
    state.thickness = Math.min(1.0, Math.max(state.thickness, 1.0 - distance));
  }

 
}
