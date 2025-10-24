# syntax=docker/dockerfile:1.4
FROM osrf/ros:jazzy-desktop-full-noble


WORKDIR /ros2_ws

RUN mkdir -p /ros2_ws/src
COPY . /ros2_ws/nina005-simple-dashboard

RUN apt-get update && apt-get install -y --no-install-recommends \
      openssh-client git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN touch /etc/ros/rosdep/sources.list.d/19-default.list

# # Initialize and update rosdep (init may already have been done in the base image; ignore failures)
RUN rosdep init || true \
	&& rosdep update

RUN mkdir -p -m 0700 /root/.ssh && ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> /root/.ssh/known_hosts

RUN --mount=type=ssh \
    vcs import /ros2_ws/src < /ros2_ws/nina005-simple-dashboard/ros2.repos --recursive

RUN echo yaml file:///ros2_ws/nina005-simple-dashboard/custom_rosdep_rules.yaml >> /etc/ros/rosdep/sources.list.d/19-default.list

RUN apt-get update && apt update && rosdep install -i --from-paths /ros2_ws/src -y

WORKDIR /ros2_ws