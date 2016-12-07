// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef COMPONENTS_MUS_WS_SERVER_WINDOW_DRAWN_TRACKER_H_
#define COMPONENTS_MUS_WS_SERVER_WINDOW_DRAWN_TRACKER_H_

#include <set>

#include "base/macros.h"
#include "components/mus/ws/server_window_observer.h"

namespace mus {

namespace ws {

class ServerWindowDrawnTrackerObserver;

// ServerWindowDrawnTracker notifies its observer any time the drawn state of
// the supplied window changes.
//
// NOTE: you must ensure this class is destroyed before the root.
class ServerWindowDrawnTracker : public ServerWindowObserver {
 public:
  ServerWindowDrawnTracker(ServerWindow* window,
                           ServerWindowDrawnTrackerObserver* observer);
  ~ServerWindowDrawnTracker() override;

  ServerWindow* window() { return window_; }

 private:
  void SetDrawn(ServerWindow* ancestor, bool drawn);

  // Adds |this| as an observer to |window_| and its ancestors.
  void AddObservers();

  // Stops observerving any windows we added as an observer in AddObservers().
  void RemoveObservers();

  // ServerWindowObserver:
  void OnWindowDestroying(ServerWindow* window) override;
  void OnWindowDestroyed(ServerWindow* window) override;
  void OnWillChangeWindowHierarchy(ServerWindow* window,
                                   ServerWindow* new_parent,
                                   ServerWindow* old_parent) override;
  void OnWindowHierarchyChanged(ServerWindow* window,
                                ServerWindow* new_parent,
                                ServerWindow* old_parent) override;
  void OnWillChangeWindowVisibility(ServerWindow* window) override;
  void OnWindowVisibilityChanged(ServerWindow* window) override;

  ServerWindow* window_;
  ServerWindowDrawnTrackerObserver* observer_;
  bool drawn_;
  // Set of windows we're observing. This is |window_| and all its ancestors.
  std::set<ServerWindow*> windows_;

  DISALLOW_COPY_AND_ASSIGN(ServerWindowDrawnTracker);
};

}  // namespace ws

}  // namespace mus

#endif  // COMPONENTS_MUS_WS_SERVER_WINDOW_DRAWN_TRACKER_H_
