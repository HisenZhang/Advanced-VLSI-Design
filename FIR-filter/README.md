# FIR Filter Design

The pipelined and parallelized FIR filter design implemented in this project demonstrates the effective utilization of hardware optimization techniques to achieve high performance and efficiency. By leveraging parallelism and pipelining, the filter can process multiple samples concurrently, resulting in improved throughput compared to a sequential implementation.

The use of 3 parallel paths allows for the distribution of the workload, enabling the filter to handle a higher input data rate. The pipelining within each MAC unit further enhances the throughput by overlapping the execution of multiple operations. This combination of parallelism and pipelining significantly reduces the overall latency and increases the processing speed of the filter.

The hardware implementation results highlight the resource utilization and performance characteristics of the design. The consistent timing performance across all paths ensures reliable operation, while the power estimation results provide insights into the power distribution and thermal characteristics of the design. The chip area utilization, as reported by the synthesis results, demonstrates the efficient use of FPGA resources.
