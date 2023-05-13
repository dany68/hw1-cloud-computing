<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Parking;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Carbon\Carbon;

class ParkingController extends Controller
{
    public function store(Request $request) {  
        if (! ($plate = $request->query('plate')) || ! ($lot = $request->query('parkingLot'))) {
            return response()->json([
                'message' => 'You must specify a plate and parking lot number.'
            ], 422);
        }
        if (Parking::where('plate', $plate)->where('exited_at', null)->first()) {
            return response()->json([
                'message' => 'This car is already parked.'
            ], 422);
        }
        if (Parking::where('parking_lot', $lot)->where('exited_at', null)->first()) {
            return response()->json([
                'message' => 'This parking lot is already in use.'
            ], 422);
        }
        return Parking::create([
            'plate' => $request->query('plate'),
            'parking_lot' => $request->query('parkingLot')
        ])->id;
    }

    public function exit(Request $request) {
        if (! ($ticketID = $request->query('ticketId'))) {
            return response()->json([
                'error' => 'You must provide a ticket Id.'
            ], 422);
        }

        $park = Parking::findOrFail($ticketID);

        if ($park->exited_at == null) {
            $park->exited_at = now();
            $park->save();
        }

        $parkedTime = Carbon::parse($park->exited_at)->diffInMinutes($park->arrived_at);

        return [
            'plate' => $park->plate,
            'parking_lot' => $park->parking_lot,
            'parked_time_in_min' => $parkedTime,
            'charge_usd' => floor($parkedTime / 15) * 2.5,
        ];
    }
}
