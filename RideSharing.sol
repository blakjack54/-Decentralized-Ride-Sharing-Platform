// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RideSharing {
    struct Ride {
        address driver;
        string origin;
        string destination;
        uint256 fare;
        bool completed;
        address passenger;
    }

    uint256 public rideCount;
    mapping(uint256 => Ride) public rides;

    event RideOffered(uint256 rideId, address driver, string origin, string destination, uint256 fare);
    event RideBooked(uint256 rideId, address passenger);
    event RideCompleted(uint256 rideId);

    function offerRide(string memory origin, string memory destination, uint256 fare) external {
        rideCount++;
        rides[rideCount] = Ride(msg.sender, origin, destination, fare, false, address(0));
        emit RideOffered(rideCount, msg.sender, origin, destination, fare);
    }

    function bookRide(uint256 rideId) external payable {
        Ride storage ride = rides[rideId];
        require(msg.value == ride.fare, "Incorrect fare amount");
        require(ride.passenger == address(0), "Ride already booked");

        ride.passenger = msg.sender;
        emit RideBooked(rideId, msg.sender);
    }

    function completeRide(uint256 rideId) external {
        Ride storage ride = rides[rideId];
        require(msg.sender == ride.passenger, "Only passenger can complete the ride");
        require(!ride.completed, "Ride already completed");

        ride.completed = true;
        payable(ride.driver).transfer(ride.fare);
        emit RideCompleted(rideId);
    }

    function getRide(uint256 rideId) external view returns (address driver, string memory origin, string memory destination, uint256 fare, bool completed, address passenger) {
        Ride storage ride = rides[rideId];
        return (ride.driver, ride.origin, ride.destination, ride.fare, ride.completed, ride.passenger);
    }
}
