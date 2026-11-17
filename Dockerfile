FROM docker.io/rocker/shiny:4.5.1@sha256:6cf5f1ebb25d4297f4155efc3964c42a1429780620d2683d25804e583673ba35

RUN apt-get update \
    && apt-get install -y --no-install-recommends cmake libicu-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/anova-explorer
COPY . .
RUN Rscript --vanilla scripts/install.R --tests \
    && Rscript --vanilla scripts/test.R \
    && chown -R shiny:shiny /opt/anova-explorer

USER shiny
ENV ANOVA_BIND_HOST=0.0.0.0 ANOVA_PORT=3838
EXPOSE 3838
CMD ["Rscript", "--vanilla", "run.R"]
