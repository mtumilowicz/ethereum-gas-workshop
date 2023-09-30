pragma solidity ^0.8.0;

contract EfficientContract {
    mapping(string => uint256) private data;
    uint256 public length;

    function addData(string calldata _newData) public {
        data[_newData]++;
        length++;
    }

    function addAll(string[] calldata _newDatas) public {
        uint256 _length = length;
        uint256 newDataLength = _newDatas.length;

        string[] memory uniqueDatas = new string[](newDataLength);
        uint256[] memory counts = new uint256[](newDataLength);

        for (uint256 i = 0; i < newDataLength; i++) {
            bool found = false;
            for (uint256 j = 0; j < uniqueDatas.length; j++) {
                if (compareStrings(_newDatas[i], uniqueDatas[j])) {
                    counts[j]++;
                    found = true;
                    break;
                }
            }
            if (!found) {
                uniqueDatas[i] = _newDatas[i];
                counts[i] = 1;
            }
        }

        for (uint256 i = 0; i < uniqueDatas.length; i++) {
            if (counts[i] > 0) {
                _length += counts[i];
                data[uniqueDatas[i]] += counts[i];
            }
        }

        length = _length;
    }

    function count(string memory _searchString) public view returns (uint) {
       return data[_searchString];
    }

    function exists(string memory _searchString) public view returns (bool) {
        return data[_searchString] > 0;
    }

    function getLength() public view returns (uint256) {
        return length;
    }

    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        bytes32 hashA = keccak256(bytes(a));
        bytes32 hashB = keccak256(bytes(b));

        return hashA == hashB;
    }
}
