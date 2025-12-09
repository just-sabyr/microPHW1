#include <iostream>
#include <vector>
using namespace std;

// Merges two subarrays of arr[].
// First subarray is arr[left..mid]
// Second subarray is arr[mid+1..right]
void merge(vector<int>& arr, vector<int>& temp, int left, int mid, int right) {
    int i = left;      // Start of left subarray
    int j = mid + 1;   // Start of right subarray
    int k = left;      // Position in temp array
    
    // Merge both subarrays into temp
    while (i <= mid && j <= right) {
        if (arr[i] <= arr[j]) {
            temp[k++] = arr[i++];
        } else {
            temp[k++] = arr[j++];
        }
    }
    
    // Copy remaining elements from left subarray
    while (i <= mid) {
        temp[k++] = arr[i++];
    }
    
    // Copy remaining elements from right subarray
    while (j <= right) {
        temp[k++] = arr[j++];
    }
    
    // Copy sorted elements back to original array
    for (i = left; i <= right; i++) {
        arr[i] = temp[i];
    }
}


// begin is for left index and end is right index
// of the sub-array of arr to be sorted
void mergeSort(vector<int>& arr, int left, int right){
    
    if (left >= right)
        return;

    int mid = left + (right - left) / 2;
    mergeSort(arr, left, mid);
    mergeSort(arr, mid + 1, right);
    merge(arr, left, mid, right);
}

// Driver code
int main(){
    
    vector<int> arr = {38, 27, 43, 10};
    int n = arr.size();

    mergeSort(arr, 0, n - 1);
    for (int i = 0; i < arr.size(); i++)
        cout << arr[i] << " ";
    cout << endl;
    
    return 0;
}













