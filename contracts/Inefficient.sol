pragma solidity ^0.8.0;

contract InefficientContract {
    string[] private data;

    function addData(string memory _newData) public {
        data.push(_newData);
    }

    function addAll(string[] memory _newDatas) public {
        for (uint i = 0; i < _newDatas.length; i++) {
            data.push(_newDatas[i]);
        }
    }

    function count(string memory _searchString) public view returns (uint) {
        uint count = 0;
        for (uint i = 0; i < data.length; i++) {
            if (compareStrings(data[i], _searchString)) {
                count++;
            }
        }
        return count;
    }

    function exists(string memory _searchString) public view returns (bool) {
        return count(_searchString) > 0;
    }

    function getLength() public view returns (uint) {
        return data.length;
    }

    function compareStrings(string memory a, string memory b) private view returns (bool) {
        bytes memory aBytes = bytes(a);
        bytes memory bBytes = bytes(b);

        if (aBytes.length != bBytes.length) {
            return false;
        } else {
            for (uint i = 0; i < aBytes.length; i++) {
                if (aBytes[i] != bBytes[i]) {
                    return false;
                }
            }
            return true;
        }
    }
}
