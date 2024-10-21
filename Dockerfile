# Use a base image with required dependencies
FROM ubuntu:20.04

# Install required packages including curl, unzip, and Java
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget \
    curl \
    unzip \
    openjdk-11-jdk \
    samtools \
    bwa \
    fastqc \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Install SRA Toolkit
RUN curl -L -o sratoolkit.current-ubuntu64.tar.gz https://ftp.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz && \
    echo "Downloaded SRA Toolkit" && \
    tar -xzf sratoolkit.current-ubuntu64.tar.gz -C /opt/ && \
    echo "Extracted SRA Toolkit" && \
    rm sratoolkit.current-ubuntu64.tar.gz && \
    mv /opt/sratoolkit* /opt/sra-toolkit-latest  # Use wildcard to match the actual extracted directory

# Set environment variables for SRA Toolkit
ENV PATH /opt/sra-toolkit-latest/bin:$PATH

# Install GATK
RUN curl -L -o gatk-4.6.0.0.zip https://github.com/broadinstitute/gatk/releases/latest/download/gatk-4.6.0.0.zip && \
    echo "Downloaded GATK" && \
    unzip gatk-4.6.0.0.zip -d /opt/ && \
    rm gatk-4.6.0.0.zip && \
    chmod +x /opt/gatk-4.6.0.0/gatk && \
    echo "GATK installed successfully"

# Set environment variables for GATK
ENV GATK_HOME /opt/gatk-4.6.0.0  # Corrected to match installed version
ENV PATH $GATK_HOME:$PATH

# Install SnpEff
RUN curl -L -o snpeff.zip https://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip/download && \
    unzip snpeff.zip -d /opt/ && \
    rm snpeff.zip

# Copy the pipeline script
COPY run_pipeline.sh /data/run_pipeline.sh

# Make the script executable
RUN chmod +x /data/run_pipeline.sh

# Set working directory
WORKDIR /data

# Default command
CMD ["bash"]
