FROM archlinux

ARG USERNAME=apple
ARG UID=1000
ARG GID=1000

RUN pacman -Syu --noconfirm --needed \
  neovim vim lolcat lazygit git curl nodejs npm wget make cmake gcc openssh \
  lua luarocks luajit starship zoxide fzf diffutils which yazi trash-cli \
  less bat man locate sudo tree \
  && pacman -Scc --noconfirm

RUN groupadd -g ${GID} ${USERNAME} && \
  useradd -m -l -u ${UID} -g ${GID} -G wheel -s /bin/bash ${USERNAME} && \
  echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel && \
  chmod 440 /etc/sudoers.d/wheel

RUN --mount=type=secret,id=user_pass \
  --mount=type=secret,id=root_pass \
  echo "${USERNAME}:$(cat /run/secrets/user_pass)" | chpasswd && \
  echo "root:$(cat /run/secrets/root_pass)" | chpasswd

WORKDIR /home/${USERNAME}

COPY .fonts/   /home/${USERNAME}/.fonts/
COPY yazi/     /home/${USERNAME}/.config/yazi/
COPY starship/ /home/${USERNAME}/.config/starship/
COPY .bashrc   /home/${USERNAME}/.bashrc
COPY nvim/     /home/${USERNAME}/.config/nvim/

RUN chown -R ${UID}:${GID} /home/${USERNAME}

USER ${USERNAME}
CMD ["/bin/bash"]
