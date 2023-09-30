pragma solidity ^0.8.0;

contract InefficientContract {
    string[] public data;

    function addData(string memory _newData) public {
        data.push(_newData);
    }

    function addAll(string[] memory _newDatas) public {
        for (uint256 i = 0; i < _newDatas.length; i++) {
            data.push(_newDatas[i]);
        }
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

    function exists(string memory _searchString) public view returns (bool) {
        for (uint256 i = 0; i < data.length; i++) {
            if (compareStrings(data[i], _searchString)) {
                return true;
            }
        }
        return false;
    }

    function getLength() public view returns (uint) {
        return data.length;
    }
}
