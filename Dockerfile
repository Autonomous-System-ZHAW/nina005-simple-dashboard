# syntax=docker/dockerfile:1
FROM osrf/ros:jazzy-desktop-full-noble

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    nano \
    openssh-client \
    python3-pip \
    ros-jazzy-foxglove-bridge && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /ros2_ws
COPY . .

RUN mkdir -p -m 0700 /root/.ssh && ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> /root/.ssh/known_hosts && \
    mkdir -p /ros2_ws/src
RUN --mount=type=ssh vcs import src < ros2.repos --recursive

RUN echo "yaml file:///ros2_ws/custom_rosdep_rules.yaml" \
      > /etc/ros/rosdep/sources.list.d/19-default.list

RUN apt-get update && \
    if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then rosdep init; fi && \
    rosdep update && \
    rosdep install -i --from-paths src --rosdistro jazzy -y && \
    rm -rf /var/lib/apt/lists/*

RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && colcon build --symlink-install"
RUN echo "source /ros2_ws/install/setup.bash" >> /root/.bashrc


COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
CMD [ "bash" ]
