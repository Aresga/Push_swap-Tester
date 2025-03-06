# Push_swap-Tester

## Description
Push_swap-Tester is a comprehensive testing suite designed to rigorously test and validate your Push_swap program. Written entirely in Shell, it provides a robust framework to ensure your solution meets the Push_swap project's requirements.

## Usage
To use the Push_swap-Tester, follow these steps:

1. **Clone the repository:**
    ```sh
    git clone https://github.com/Aresga/Push_swap-Tester.git
    ```

2. **Navigate to the repository directory:**
    ```sh
    cd Push_swap-Tester
    ```

3. **Prepare your Push_swap program:**
   - Compile your Push_swap program and ensure the executable is named `push_swap`.
   - Place the `push_swap` executable in the same directory as the tester.

4. **Run the tester script:**
   - For Linux users:
     ```sh
     ./testlinux.sh [Numbers count] [Number of iterations]
     ```
   - For macOS users:
     ```sh
     ./testmac.sh [Numbers count] [Number of iterations]
     ```
   - `[Numbers count]`: The number of integers to generate for each test (default is 100).
   - `[Number of iterations]`: The number of test iterations to run (default is 10).

5. **View the results:**
   - The script will execute a series of tests with randomly generated numbers.
   - It will display the results for each test, indicating whether your program passes or fails.

## Requirements
Ensure the following files are present in the same directory as the tester:

- Your compiled `push_swap` executable.
- The appropriate checker program:
  - `checker_linux` for Linux users.
  - `checker_mac` for macOS users.

**Note:** The checker programs are part of the Push_swap project and must be compiled separately. Ensure you have the correct version for your operating system.

## Examples
Here are some example commands:

- **Run the default tests (100 numbers, 10 iterations):**
  - Linux:
    ```sh
    ./testlinux.sh
    ```
  - macOS:
    ```sh
    ./testmac.sh
    ```

- **Run custom tests (e.g., 500 numbers, 20 iterations):**
  - Linux:
    ```sh
    ./testlinux.sh 500 20
    ```
  - macOS:
    ```sh
    ./testmac.sh 500 20
    ```

## How It Works
The tester generates random sets of integers and passes them to your `push_swap` program. It then uses the corresponding checker program (`checker_linux` or `checker_mac`) to verify that the sequence of operations produced by `push_swap` correctly sorts the stack. Additionally, it may evaluate the efficiency of your solution by checking the number of operations against the expected limits for the given input size.
