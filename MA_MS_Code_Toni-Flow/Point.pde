import java.util.List;
import java.util.LinkedList;

class DotState {
  float transparency = USE_OPACITY ? 1 : 0;
  float thickness = 0.5;
  float radius = INITIAL_DOT_RADIUS;
}

class ActionMetadata {
  Action action;
  int outdatedTimestamp;
  
  ActionMetadata(Action action) {
    this.action = action;
    this.outdatedTimestamp = millis() + ACTION_LIFETIME_MILLIS; 
  }
  
  boolean isOutdated() {
    return outdatedTimestamp < millis();
  }
}

class Dot {
  //boolean startInteraction = false;
  int lastInteractionTimestamp = -INTERACTION_GRACE_MILLIS;
  boolean actionsChangedSinceLastPaint = true;
  
  List<ActionMetadata> actions = new LinkedList();
  
  float x;
  float y;
  
  Dot(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void paint() {
    cleanActions();
    if(!actionsChangedSinceLastPaint) {
      return;
    }
    actionsChangedSinceLastPaint = false;

    DotState state = new DotState();
    for(ActionMetadata action : actions) {
      action.action.apply(state);
    }

    if(state.transparency >= 1 || state.thickness <= 0) {
      return;
    }
    float radius = state.thickness * state.radius;
    fill(BACKGROUND_COLOR);
    float x = width - this.x;
    rect(x - CENTER_DISTANCE/2, y - CENTER_DISTANCE/2, CENTER_DISTANCE, CENTER_DISTANCE);
    fill(DOT_COLOR, 255 * (1 - state.transparency));
    ellipse(x, y, radius, radius);    
  }
  
  void cleanActions() {
    while(actions.size() > 0 && actions.get(0).isOutdated()) {
      actions.remove(0);
      actionsChangedSinceLastPaint = true;
    }
  }
  
  void addAction(Action action) {
    this.actions.add(new ActionMetadata(action));
    actionsChangedSinceLastPaint = true;
  }

  //double distance(float x, float y, int maxDistance) {
  //  if(Math.abs(mouseX - x) > maxDistance || Math.abs(mouseY - y) > maxDistance) {
  //    // Abkürzung
  //    return maxDistance;
  //  } 
  //  return dist(this.x, this.y, x, y);
  //}
  
    double distance(float x, float y, int maxDistance) {
    float d = dist(x, y, this.x, this.y);
    if (d > maxDistance) {
      d = maxDistance;
    }
    
    return d;
    
    
    
    /*if (Math.abs(mouseX - x) > maxDistance || Math.abs(mouseY - y) > maxDistance) {
      // Abkürzung
      return maxDistance;
    }

    return Math.sqrt(Math.pow(this.x - x, 2) + Math.pow(this.y - y, 2));*/
  }
}
