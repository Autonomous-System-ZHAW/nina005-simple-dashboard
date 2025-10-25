# syntax=docker/dockerfile:1
FROM osrf/ros:jazzy-desktop-full-noble

RUN apt-get update && apt-get install -y --no-install-recommends \
    nano openssh-client git ca-certificates ros-jazzy-foxglove-bridge && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /ros2_ws

RUN mkdir -p /ros2_ws/src
COPY . /ros2_ws/nina005-simple-dashboard

RUN mkdir -p -m 0700 /root/.ssh && ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> /root/.ssh/known_hosts
RUN --mount=type=ssh \
vcs import /ros2_ws/src < /ros2_ws/nina005-simple-dashboard/ros2.repos --recursive

RUN touch /etc/ros/rosdep/sources.list.d/19-default.list
RUN echo yaml file:///ros2_ws/nina005-simple-dashboard/custom_rosdep_rules.yaml >> /etc/ros/rosdep/sources.list.d/19-default.list

RUN apt-get update && \
    rosdep init || true && \
    rosdep update && \
    rosdep install -i --from-paths /ros2_ws/src -y && \
    rm -rf /var/lib/apt/lists/*

RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && colcon build --symlink-install"
RUN echo "source /ros2_ws/install/setup.bash" >> /root/.bashrc

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
CMD [ "bash" ]
