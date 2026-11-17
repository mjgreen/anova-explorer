# ANOVA explorer

A local, interactive demonstration of one-way ANOVA, made by Matt Green with R
and Shiny. Change the means, standard deviations and sample size of three
simulated groups and see what changes in the plot, F statistic and p-value.
All observations are generated in the app: no participant records are included
or uploaded, and no account or hosted service is required to use it.

## Run on your computer

1. Install [R 4.5.1](https://cran.r-project.org/) and download this repository
   using **Code → Download ZIP**. Extract the ZIP. You can also clone it with Git.
2. Open a terminal in the extracted `anova-explorer` folder. Install the locked
   dependencies once:

   ```sh
   Rscript --vanilla scripts/install.R
   ```

   This downloads packages from the public repositories named in the lockfiles
   and installs them in this folder's `.library` directory. It does not update
   your global R library. The first installation can take some time. The
   lockfile records R 4.5.1; other R versions have not been accepted for this
   distribution. On Windows, source packages can require matching Rtools; on
   macOS they can require Xcode command-line tools and a Fortran compiler.
   Linux needs the development libraries listed in the Dockerfile. The
   container route below supplies a pinned R/Linux environment.
3. Start the app:

   ```sh
   Rscript --vanilla run.R
   ```

4. Open **http://127.0.0.1:3841/** in your browser. Leave the terminal running
   while using the app; press **Ctrl+C** there to stop it. Once packages are
   installed, the app can run without an Internet connection. Its optional
   Matt Green link opens an external website.

If that port is already in use, set `ANOVA_PORT` to another free port before
running the command. The default listener accepts connections only from your
own computer. Avoid exposing a local development session to an untrusted network.

## Container route

With Docker or Podman installed, build the public-source distribution:

```sh
docker build -t anova-explorer:local .
docker run --rm --name anova-explorer -p 127.0.0.1:3841:3838 anova-explorer:local
```

Open **http://127.0.0.1:3841/**. The image uses a digest-pinned public Rocker
R 4.5.1 base and installs the same locked R packages. It runs as a non-root
user. Replace `docker` with `podman` if that is your installed engine. Building
needs Internet access and may take several minutes; running the completed
image does not. OS package repositories can change, so a later image rebuild
is not promised to be byte-identical.

## Try the exercise

The starting teaching sample has 20 simulated participants per group, population
means of 24, 25 and 26, and population SDs of 5. It starts at **p = .769**.
Predict the effect of changing one kind of setting, move the sliders, then
explain what changed. The app includes a follow-up after your first solution.

Sliders reuse the same random draw banks, which lets you compare settings
without replacing all observations. Increasing sample size retains the earlier
participants and adds more. **New random sample** deliberately replaces the
draws. **Reset exercise** restores all seven sliders and the exact starting
sample, without restarting the independent stream of later random samples.

These are simulated groups for learning. This app is not an analysis uploader
and does not provide a route for entering clinical or participant data.

## Verify the installation

Install the separate locked test dependencies and run the supplied checks:

```sh
Rscript --vanilla scripts/install.R --tests
Rscript --vanilla scripts/test.R
```

The checks cover app construction, the ANOVA and Levene calculations, the
fixed teaching result and three routes to p < .001, stable samples, reset and
resampling, and every server output at the slider limits. The container build
runs the same checks. They do not replace a visual check in your own browser.

## Source, data and licence

This is an app-only distribution of the ANOVA source maintained within Stats
Helpdesk. `SOURCE.json` identifies the source revision and exported file hashes.
It contains no private repository history, deployment secrets, request records,
student documents or production server state. The app code is MIT-licensed, as
declared in its existing `DESCRIPTION`; see `LICENSE`. R and dependency packages
retain their own licences and attribution, recorded in the lockfiles and their
installed package metadata. No third-party package binaries are bundled here.
